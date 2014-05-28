/**
 * Copyright (C) 2010 Geoff Johnson
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2.1 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 *
 * Author:
 *  Steve Roy <sroy1966@gmail.com>
 */
using Cld;
using Gsl;

/**
 * A data series or array of values
 */
public class Cld.DataSeries : Cld.AbstractContainer {
    /**
     * {@inheritDoc}
     */
    public override string id { get; set; }

    /**
     * {@inheritDoc}
     */
    private Gee.Map<string, Cld.Object> _objects;
    public override Gee.Map<string, Cld.Object> objects {
        get { return (_objects); }
        set { update_objects (value); }
    }

    /**
     * {@inheritDoc}
     */
    public override void update_objects (Gee.Map<string, Cld.Object> val) {
        _objects = val;
    }

    /**
     * The number of elements in the series
     */
    public int length { get; set; default = 3; }

    /**
     * The stride is the step-size from one element to the next. Setting this
     * property will affect the number of points that are used in the calculation
     * of the mean value, for example.
     */
    public int stride { get; set; default = 1; }

    private double _mean_value;
    public double mean_value {
        get {
            _mean_value = Gsl.Stats.mean (buffer, stride * sizeof (double), buffer.length * sizeof (double));
            return _mean_value;
        }
    }

    /**
     * The reference id of the scalable channel that is buffered.
     */
    public string chanref { get; set; }

    /**
     * The channel that is buffered
     */
    public weak Cld.ScalableChannel channel { get; set; }

    /**
     * The reference channel value type that the data series derives from
     */
    public string vtype { get; set; default = "scaled"; }

    /**
     * XXX This may belong somewhere else but is left here for future development.
     * An array of indexes of the values in the data series that will be assigned
     * to a virtual channel.
     */
    public int[]? taps { get; set; default = null; }

    private double [] buffer;
    private int j;

    public signal void new_value (string id, double val);

    /**
     * Default constructor
     */
    construct {
        j = 0;
    }
    public DataSeries () {
        _objects = new Gee.TreeMap<string, Cld.Object> ();
    }

    /**
     * Construction using an xml node.
     *
     * @param node XML tree node containing configuration for a DataSeries object.
     */
    public DataSeries.from_xml_node (Xml.Node *node) {
        string value;
        _objects = new Gee.TreeMap<string, Cld.Object> ();

        if (node->type == Xml.ElementType.ELEMENT_NODE &&
            node->type != Xml.ElementType.COMMENT_NODE) {
            id = node->get_prop ("id");
            /* iterate through node children */
            for (Xml.Node *iter = node->children; iter != null; iter = iter->next) {
                if (iter->name == "property") {
                    switch (iter->get_prop ("name")) {
                        case "length":
                            value = iter->get_content ();
                            length = int.parse (value);
                            Cld.debug ("%s length: %d", id, this.length);
                            break;
                        case "chanref":
                            value = iter->get_content ();
                            chanref = value;
                            break;
                        case "vtype":
                            value = iter->get_content ();
                            vtype = value;
                            break;
                        case "taps":
                            value = iter->get_content ();
                            string [] tapstring =  value.split_set (", :/", -1);
                            Cld.debug ("tapstring.length: %d", tapstring.length);
                            taps = new int [tapstring.length];
                            int len = length;
                            for (int i = 0; i < tapstring.length; i++) {
                                taps [i] = int.parse (tapstring [i]);
                                Cld.debug ("taps [%d]: %d", i, taps [i]);
                                Cld.Object object = new VChannel ();
                                (object as VChannel).id = "vc-%s-%d".printf (this.id, taps [i]);
                                (object as VChannel).tag = "%s [%d]".printf (this.id, taps [i]);
                                (object as VChannel).num = taps [i];
                                add (object);
                            }
                            break;
                        default:
                            break;
                    }
                }
            }
        }
        buffer = new double [length];
        for (int i = 0; i < length; i++) {
            buffer [i] = 0.0;
        }
    }

    /**
     * Add a object to the array list of objects
     *
     * @param object object to add to the list
     */
    public void add (Cld.Object object) {
        objects.set (object.id, object);
    }


    /**
     * Push a new value into the buffer of values and relay generate a new value signal.
     */
    public void connect_input () {
        (channel as ScalableChannel).new_value.connect ((id, val) => {
            buffer [j] = val;
            /*
            Cld.debug ("buffer [0 : %d]: ", buffer.length);
            for (int i = 0; i < buffer.length; i++) {
                Cld.debug ("%.3f  ", buffer [i]);
            }
            Cld.debug ("\n");
            */
            new_value (this.id, buffer [j]);
            j++;
            if (j > (buffer.length - 1)) {
                j = 0;
            }
        });
    }

    /**
     * A convenience method used to retrieve a buffered value from its index.
     * @param n The index of the value to be retrieved
     * @param val The n_th buffered value
     * @return true if succesful
     */
    public bool get_nth_value (int n, out double val) {
        int i;
        i = (j - n) % length;
        if (i < 0) {
            i = length + ((j - n) % length);
        }
        if ((i > length) || (i < 0)) {
            Cld.debug ("DataSeries.get_nth_value (n) Failed!");

            return false;
        } else {
            val = buffer [i];
            return true;
        }
    }

    /**
     * XXX Virtual channels from a list of tap values may not be that useful.
     */
    public void activate_vchannels () {
        foreach (Cld.Object object in objects.values) {
            if (object is VChannel && object.id.contains (this.id)) {
                (object as VChannel).desc = "%s [n - %d]".printf (((channel as Channel).id),
                            (object as VChannel).num);
                (object as VChannel).calref = (channel as ScalableChannel).calref;
                (object as VChannel).calibration = (channel as ScalableChannel).calibration;
                (channel as ScalableChannel).new_value.connect ((id, val) => {
                    double nth_value;
                    if (get_nth_value ((object as VChannel).num, out nth_value)) {
                        (object as VChannel).raw_value = nth_value;
                    }
                });
            }
        }
    }

    public override string to_string () {

        return base.to_string ();
    }
}
