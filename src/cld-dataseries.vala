/**
 * libcld
 * Copyright (c) 2015, Geoff Johnson, All rights reserved.
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 3.0 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library.
 */

using Cld;
using Gsl;

/**
 * A data series or array of values
 */
public class Cld.DataSeries : Cld.AbstractContainer, Cld.Connector {

    /**
     * The number of elements in the series
     */
    [Description(nick="Length", blurb="The number of elements in the series")]
    public int length { get; set; default = 3; }

    /**
     * The stride is the step-size from one element to the next. Setting this
     * property will affect the number of points that are used in the calculation
     * of the mean value, for example.
     */
    [Description(nick="Stride", blurb="The step size from one sample to the next")]
    public int stride { get; set; default = 1; }

    private double _mean_value;
    [Description(nick="Mean", blurb="The average value of the series")]
    public double mean_value {
        get {
            _mean_value = Gsl.Stats.mean (buffer, stride, buffer.length);
            return _mean_value;
        }
    }

    /**
     * The reference id of the scalable channel that is buffered.
     */
    [Description(nick="Channel Reference", blurb="The URI of the referenced channel")]
    public string chref { get; set; }

    private weak Cld.ScalableChannel? _channel = null;

    /**
     * The channel that is buffered
     */
    [Description(nick="Channel", blurb="The referenced channel")]
    public Cld.ScalableChannel channel {
        get {
            if (_channel == null) {
                var channels = get_children (typeof (Cld.ScalableChannel));
                foreach (var chan in channels.values) {
                    _channel = chan as Cld.ScalableChannel;
                }
            }
            return _channel;
        }
        set {
            objects.unset_all (get_children (typeof (Cld.ScalableChannel)));
            objects.set (value.id, value);
            _channel = value;
        }
    }

    /**
     * XXX This may belong somewhere else but is left here for future development.
     * An array of indexes of the values in the data series that will be assigned
     * to a virtual channel.
     */
    public int[]? taps { get; set; default = null; }

    private double[] buffer;
    private int j;

    public signal void new_value (string id, double val);

    /**
     * Default constructor
     */
    construct {
        j = 0;
    }

    public DataSeries () {
        objects = new Gee.TreeMap<string, Cld.Object> ();
    }

    /**
     * Construction using an xml node.
     *
     * @param node XML tree node containing configuration for a DataSeries object.
     */
    public DataSeries.from_xml_node (Xml.Node *node) {
        string value;
        this.node = node;
        objects = new Gee.TreeMap<string, Cld.Object> ();

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
                            debug ("%s length: %d", id, this.length);
                            break;
                        case "chref":
                            value = iter->get_content ();
                            chref = value;
                            break;
                        case "taps":
                            value = iter->get_content ();
                            string[] tapstring =  value.split_set (", :/", -1);
                            debug ("tapstring.length: %d", tapstring.length);
                            taps = new int[tapstring.length];
                            int len = length;
                            for (int i = 0; i < tapstring.length; i++) {
                                taps[i] = int.parse (tapstring[i]);
                                debug ("taps[%d]: %d", i, taps[i]);
                                Cld.Object object = new VChannel ();
                                (object as VChannel).id = "vc-%s-%d".printf (this.id, taps[i]);
                                (object as VChannel).tag = "%s[%d]".printf (this.id, taps[i]);
                                (object as VChannel).set_num (taps[i]);
                                try {
                                    add (object);
                                } catch (Cld.Error.KEY_EXISTS e) {
                                    error (e.message);
                                }
                            }
                            break;
                        case "alias":
                            alias = iter->get_content ();
                            break;
                        default:
                            break;
                    }
                }
            }
        }
        buffer = new double[length];
        for (int i = 0; i < length; i++) {
            buffer[i] = 0.0;

        }
    }

    /**
     * Push a new value into the buffer of values and relay generate a new value signal.
     * Connect the notify signals
     */
    public void connect_signals () {
        Type type = get_type ();
        ObjectClass ocl = (ObjectClass)type.class_ref ();

        foreach (ParamSpec spec in ocl.list_properties ()) {
            notify[spec.get_name ()].connect ((s, p) => {
            update_node ();
            });
        }

        (channel as ScalableChannel).new_value.connect ((id, val) => {
            buffer[j] = val;
            /*
            debug ("buffer[0 : %d]: ", buffer.length);
            for (int i = 0; i < buffer.length; i++) {
                debug ("%.3f  ", buffer[i]);
            }
            debug ("\n");
            */
            new_value (this.id, buffer[j]);
            j++;

            if (j > (buffer.length - 1)) {
                j = 0;
            }
        });
    }

    /**
     * Update the XML Node for this object.
     */
    private void update_node () {
        if (node != null) {
            if (node->type == Xml.ElementType.ELEMENT_NODE &&
                node->type != Xml.ElementType.COMMENT_NODE) {
                /* iterate through node children */
                for (Xml.Node *iter = node->children;
                     iter != null;
                     iter = iter->next) {
                    if (iter->name == "property") {
                        switch (iter->get_prop ("name")) {
                            case "length":
                                iter->set_content (length.to_string ());
                                break;
                            case "chref":
                                iter->set_content (chref);
                                break;
                            default:
                                break;
                        }
                    }
                }
            }
        }
    }


    /**
     * A convenience method used to retrieve a buffered value from its index.
     *
     * @param n The index of the value to be retrieved
     * @param val The n_th buffered value
     * @return true if succesful
     */
    public bool get_nth_value (int n, out double val) {
        int i = (j - n) % length;

        if (i < 0) {
            i = length + ((j - n) % length);
        }

        if ((i > length) || (i < 0)) {
            debug ("DataSeries.get_nth_value (n) Failed!");
            return false;
        } else {
            val = buffer[i];
            return true;
        }
    }

    /**
     * XXX Virtual channels from a list of tap values may not be that useful.
     */
    public void activate_vchannels () {
        foreach (Cld.Object object in objects.values) {
            if (object is VChannel && object.id.contains (this.id)) {
                (object as VChannel).desc = "%s[n - %d]".printf (((channel as Channel).id),
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

    /**
     * {@inheritDoc}
     */
    public override void set_object_property (string name, Cld.Object object) {
        switch (name) {
            case "channel":
                if (object is Cld.ScalableChannel) {
                    channel = object as Cld.ScalableChannel;
                    chref = channel.uri;
                }
                break;
            default:
                break;
        }
    }
}
