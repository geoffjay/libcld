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

/**
 * Analog input channel used with measurements and other control functions.
 */
public class Cld.AIChannel : Cld.AbstractChannel, Cld.AChannel, Cld.IChannel,
                                Cld.ScalableChannel, Cld.Connector {
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
    private Cld.Calibration _calibration = null;
    public virtual Cld.Calibration calibration {
        get {
            if (_calibration == null) {
                var calibrations = get_children (typeof (Cld.Calibration));
                foreach (var cal in calibrations.values) {

                    /* this should only happen once */
                    message ("this should only happen once");
                    /*return cal as Cld.Calibration;*/
                    _calibration  = cal as Cld.Calibration;
                }
            }

            return _calibration;
            /*return null;*/
        }
        set {
            objects.unset_all (get_children (typeof (Cld.Calibration))) ;
            objects.set (value.id, value);
            _calibration = null;
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
    public virtual double ssdev_value { get; private set; }

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
            return ((calibration != null) ? calibration.apply (_raw_value[0]) : -99.9);
        }
    }

    /**
     * Read only previous unaveraged value, used with control loops and filters.
     * XXX consider name change
     */
    public double previous_value {
        get { return ((calibration != null) ? calibration.apply (_raw_value[1]) : -99.9); }
    }

    /**
     * Read only previous previous unaveraged value, used with control loops and
     * filters.
     * XXX consider name change
     */
    public double past_previous_value {
        get { return ((calibration != null) ? calibration.apply (_raw_value[2]) : -99.9); }
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
    }

    /**
     * Connect all the notify signals that should require the node to update
     */
    private void connect_signals () {
        notify["tag"].connect ((s, p) => {
            message ("Property %s changed for %s", p.get_name (), uri);
            update_node ();
        });

        notify["desc"].connect ((s, p) => {
            message ("Property %s changed for %s", p.get_name (), uri);
            update_node ();
        });

        notify["num"].connect ((s, p) => {
            message ("Property %s changed for %s", p.get_name (), uri);
            update_node ();
        });

        notify["subdevnum"].connect ((s, p) => {
            message ("Property %s changed to %d for %s", p.get_name (), subdevnum,  uri);
            update_node ();
        });
        notify["raw-value-list-size"].connect ((s, p) => {
            message ("Property %s changed for %s", p.get_name (), uri);
            update_node ();
        });

        notify["calref"].connect ((s, p) => {
            message ("Property %s changed for %s", p.get_name (), uri);
            update_node ();
        });

        notify["range"].connect ((s, p) => {
            message ("Property %s changed for %s", p.get_name (), uri);
            update_node ();
        });

        notify["alias"].connect ((s, p) => {
            message ("Property %s changed for %s", p.get_name (), uri);
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

            for (Xml.Node *iter = node->children; iter != null; iter = iter->next) {
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
                            break;
                        case "naverage":
                            iter->set_content (raw_value_list_size.to_string ());
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
     *
     * XXX: This isn't necessary and gives an incorrect average until the list
     *      fills.
     */
    [Deprecated (since="0.3")]
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
                /* throw away the extra values */
                for (int i = raw_value_list_size; i < raw_value_list.size; i++) {
                    (raw_value_list as Gee.LinkedList<double?>).poll_head ();
                }
            }

            /* update the average */
            update_avg_value ();
            update_ssdev_value ();
        }

        /* update the scaled value */
        scaled_value = (calibration != null) ? calibration.apply (_raw_value [0]) : -99.9;
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

    /**
     * Update the value for the running average that represents the contents
     * of the raw data list.
     */
    private void update_ssdev_value () {
        double[] list = new double [raw_value_list.size];
        var l = raw_value_list.to_array ();
        for (int i = 0; i < l.length; i++)
            list [i] = l [i];
        ssdev_value = Gsl.Stats.sd (list, 1, list.length);
    }
}
