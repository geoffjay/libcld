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
 * Analog output channel used for control and logging.
 */
public class Cld.AOChannel : Cld.AbstractChannel, Cld.AChannel, Cld.OChannel, Cld.ScalableChannel {

    /* Property backing fields. */
    private double _scaled_value = 0.0;
    private double _raw_value = 0.0;

    /**
     * {@inheritDoc}
     */
    [Description(nick="Calibration Reference", blurb="The URI of the calibration")]
    public virtual string calref { get; set; }

    /**
     * {@inheritDoc}
     */
    private Cld.Calibration _calibration = null;
    [Description(nick="Calibration", blurb="The calibration used to generate a scaled value")]
    public virtual Calibration calibration {
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
    [Description(nick="Range", blurb="The range that the device uses")]
    public virtual int range { get; set; }

    /**
     * {@inheritDoc}
     */
    [Description(nick="Raw Value", blurb="The non-scaled value")]
    public virtual double raw_value {
        get { return _raw_value; }
        set {
            _raw_value = value;
            scaled_value = calibration.apply (_raw_value);
        }
    }

    /**
     * {@inheritDoc}
     */
    [Description(nick="Scaled Value", blurb="The value with scaling applied")]
    public virtual double scaled_value {
        get { return _scaled_value; }
        private set {
            _scaled_value = value;
            new_value (id, value);
        }
    }

    /**
     * {@inheritDoc}
     */
    [Description(nick="Average Value", blurb="The average of the scaled value")]
    public virtual double avg_value { get; private set; }

    /**
     * {@inheritDoc}
     */
    [Description(nick="Standard Deviation", blurb="The sample standard deviation of the scaled value")]
    public virtual double ssdev_value { get; private set; }

    /**
     * Wrong spot to store information about control loop, should move it.
     */
    public bool manual { get; set; }

    /* default constructor */
    public AOChannel () {
        /* set defaults */
        set_num (0);
        //this.devref = "dev0";
        this.tag = "CH0";
        this.desc = "Output Channel";

        raw_value = 0.0;
        connect_signals ();
    }

    public AOChannel.from_xml_node (Xml.Node *node) {
        string val;

        this.node = node;
        if (node->type == Xml.ElementType.ELEMENT_NODE &&
            node->type != Xml.ElementType.COMMENT_NODE) {
            id = node->get_prop ("id");
            //devref = node->get_prop ("ref");
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
                            set_num (int.parse (val));
                            break;
                        case "subdevnum":
                            val = iter->get_content ();
                            subdevnum = int.parse (val);
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
            //message ("Property %s changed for %s", p.get_name (), uri);
            update_node ();
        });

        notify["desc"].connect ((s, p) => {
            //message ("Property %s changed for %s", p.get_name (), uri);
            update_node ();
        });

        notify["num"].connect ((s, p) => {
            //message ("Property %s changed for %s", p.get_name (), uri);
            update_node ();
        });

        notify["subdevnum"].connect ((s, p) => {
            //message ("Property %s changed to %d for %s", p.get_name (), subdevnum,  uri);
            update_node ();
        });

        notify["calref"].connect ((s, p) => {
            //message ("Property %s changed for %s", p.get_name (), uri);
            update_node ();
        });

        notify["range"].connect ((s, p) => {
            //message ("Property %s changed for %s", p.get_name (), uri);
            update_node ();
        });

        notify["alias"].connect ((s, p) => {
            //message ("Property %s changed for %s", p.get_name (), uri);
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
                    debug ("property: %s", iter->get_prop ("name"));
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
                            //message ("Writing %s to XML node for subdevnum", subdevnum.to_string ());
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
     * {@inheritDoc}
     **/
    public override void set_object_property (string name, Cld.Object object) {
        switch (name) {
            case "calibration":
                if (object is Cld.Calibration) {
                    calibration = object as Cld.Calibration;
                    calref = (object as Cld.Calibration).uri;
                    //message ("Calibration for %s changed to %s", uri, calibration.uri);
                }
                break;
            default:
                break;
        }
    }
}
