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
 *  Geoff Johnson <geoff.jay@gmail.com>
 */

/**
 * Analog input channel used with measurements and other control functions.
 */
public class Cld.AIChannel : Cld.AbstractChannel, Cld.AChannel, Cld.IChannel, Cld.ScalableChannel {
    /**
     * Property backing fields to allow the channels to have a short history
     * for use with control loop calculations.
     */
    private double[] _raw_value = { 0.0, 0.0, 0.0 };
    private double[] _avg_value = { 0.0, 0.0, 0.0 };
    private double[] _scaled_value = { 0.0, 0.0, 0.0 };


    /**
     * {@inheritDoc}
     */
    public virtual string calref { get; set; }

    /**
     * {@inheritDoc}
     */
    public virtual Calibration calibration {
        get {
            var calibrations = get_children (typeof (Cld.Calibration));
            foreach (var cal in calibrations.values) {

                /* this should only happen once */
                return cal as Cld.Calibration;
            }

            return null;
        }
        set {
            objects.unset_all (get_children (typeof (Cld.Calibration))) ;
            objects.set (value.id, value);
        }
    }

    /**
     * {@inheritDoc}
     */
    public virtual int range { get; set; }

    /**
     * {@inheritDoc}
     */
    public virtual double raw_value {
        get { return _raw_value[0]; }
        set {
            lock (_raw_value) {
                _raw_value[2] = _raw_value[1];
                _raw_value[1] = _raw_value[0];
                _raw_value[0] = value;
            }
        }
    }

    /**
     * {@inheritDoc}
     */
    public virtual double avg_value {
        get { return _avg_value[0]; }
        private set {
            _avg_value[2] = _avg_value[1];
            _avg_value[1] = _avg_value[0];
            _avg_value[0] = value;
        }
    }

    /**
     * {@inheritDoc}
     */
    public virtual double scaled_value {
        get { return _scaled_value[0]; }
        private set {
            _scaled_value[2] = _scaled_value[1];
            _scaled_value[1] = _scaled_value[0];
            _scaled_value[0] = value;
            new_value (id, value);
        }
    }

    /**
     * Read only current unaveraged value, used with control loops and filters.
     * XXX consider name change
     */
    public double current_value {
        get {
            /* XXX why not just return scaled_value ??? */
            return calibration.apply (_raw_value[0]);
        }
    }

    /**
     * Read only previous unaveraged value, used with control loops and filters.
     * XXX consider name change
     */
    public double previous_value {
        get { return calibration.apply (_raw_value[1]); }
    }

    /**
     * Read only previous previous unaveraged value, used with control loops and
     * filters.
     * XXX consider name change
     */
    public double past_previous_value {
        get { return calibration.apply (_raw_value[2]); }
    }

    /**
     * Controls the size of the list that holds raw values and is used as the
     * size of the window for the moving average.
     *
     * XXX should be max list size, naming is confusing
     * XXX if value != current the list should be resized to reflect the change
     */
    private int _raw_value_list_size = 1;
    public int raw_value_list_size {
        get { return _raw_value_list_size; }
        set {
            if (value < 1)
                _raw_value_list_size = 1;
            else
                _raw_value_list_size = value;
        }
    }

    private Gee.List<double?> raw_value_list = new Gee.LinkedList<double?> ();

    /**
     * Default construction.
     */
    public AIChannel () {
        /* set defaults */
        this.num = 0;
        this.devref = "dev0";
        this.tag = "CH0";
        this.desc = "Input Channel";
        preload_raw_value_list ();
        connect_signals ();
    }

    /**
     * Alternate construction that uses an XML node to set the object up.
     */
    public AIChannel.from_xml_node (Xml.Node *node) {
        string val;
        this.node = node;

        if (node->type == Xml.ElementType.ELEMENT_NODE &&
            node->type != Xml.ElementType.COMMENT_NODE) {
            id = node->get_prop ("id");
            devref = node->get_prop ("ref");
            /* iterate through node children */
            for (Xml.Node *iter = node->children;
                 iter != null;
                 iter = iter->next) {
                if (iter->name == "property") {
                    switch (iter->get_prop ("name")) {
                        case "tag":
                            tag = iter->get_content ();
                            break;
                        case "desc":
                            desc = iter->get_content ();
                            break;
                        case "num":
                            val = iter->get_content ();
                            num = int.parse (val);
                            break;
                        case "subdevnum":
                            val = iter->get_content ();
                            subdevnum = int.parse (val);
                            break;
                        case "naverage":
                            val = iter->get_content ();
                            raw_value_list_size = int.parse (val);
                            break;
                        case "calref":
                            /* this should maybe be an object property,
                             * possibly fix later */
                            calref = iter->get_content ();
                            break;
                        case "range":
                            val = iter->get_content ();
                            range = int.parse (val);
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
        connect_signals ();
        preload_raw_value_list ();
    }

    /**
     * Connect all the notify signals that should require the node to update
     */
    private void connect_signals () {
        notify["tag"].connect ((s, p) => {
            Cld.debug ("Property %s changed for %s", p.get_name (), uri);
            update_node ();
        });

        notify["desc"].connect ((s, p) => {
            Cld.debug ("Property %s changed for %s", p.get_name (), uri);
            update_node ();
        });

        notify["num"].connect ((s, p) => {
            Cld.debug ("Property %s changed for %s", p.get_name (), uri);
            update_node ();
        });

        notify["subdevnum"].connect ((s, p) => {
            Cld.debug ("Property %s changed to %d for %s", p.get_name (), subdevnum,  uri);
            update_node ();
        });
        /* FIXME: This signal does not seem to connect ??? */
        notify["raw_value_list_size"].connect ((s, p) => {
            Cld.debug ("Property %s changed for %s", p.get_name (), uri);
            update_node ();
        });

        notify["calref"].connect ((s, p) => {
            Cld.debug ("Property %s changed for %s", p.get_name (), uri);
            update_node ();
        });

        notify["range"].connect ((s, p) => {
            Cld.debug ("Property %s changed for %s", p.get_name (), uri);
            update_node ();
        });
    }

    /**
     * Update the XML Node for this object.
     */
    private void update_node () {
        if (node->type == Xml.ElementType.ELEMENT_NODE &&
            node->type != Xml.ElementType.COMMENT_NODE) {
            /* iterate through node children */
            for (Xml.Node *iter = node->children;
                 iter != null;
                 iter = iter->next) {
                if (iter->name == "property") {
                    switch (iter->get_prop ("name")) {
                        case "tag":
                            iter->set_content (tag);
                            break;
                        case "desc":
                            iter->set_content (desc);
                            break;
                        case "num":
                            iter->set_content (num.to_string ());
                            break;
                        case "subdevnum":
                            iter->set_content (subdevnum.to_string ());
                            Cld.debug ("Writing %s to XML node for subdevnum", subdevnum.to_string ());
                            break;
                        case "naverage":
                            iter->set_content (raw_value_list_size.to_string ());
                            Cld.debug ("node avg set to %s", iter->get_content ());
                            break;
                        case "calref":
                            iter->set_content (calref);
                            break;
                        case "range":
                            iter->set_content (range.to_string ());
                            break;
                        case "alias":
                            iter->set_content (alias);
                            break;
                        default:
                            break;
                    }
                }
            }
        }
    }

    /**
     * The previous version had some issues where the list size was 0 to begin
     * with, this is just to avoid that.
     */
    private void preload_raw_value_list () {
        for (int i = 0; i < raw_value_list_size; i++) {
            add_raw_value (0.0);
        }
    }

    public void add_raw_value (double value) {

        lock (raw_value_list) {
            /* for now add it to the list and the raw value array */
            raw_value_list.add (value);
            raw_value = value;

            if (raw_value_list.size > raw_value_list_size) {
                /* throw away the value */
                (raw_value_list as Gee.LinkedList<double?>).poll_head ();
            }

            /* update the average */
            update_avg_value ();
        }

        /* update the scaled value */
        scaled_value = calibration.apply (avg_value);
    }

    /**
     * Update the value for the running average that represents the contents
     * of the raw data list.
     */
    private void update_avg_value () {
        var sum = 0.0;
        if (raw_value_list.size > 0) {
            foreach (var value in raw_value_list) {
                sum += value;
            }
            avg_value = sum / raw_value_list.size;
        } else {
            avg_value = 0.0;
        }
    }
}
