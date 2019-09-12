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
 * Virtual channel to be used to execute expressions or just as a dummy channel
 * with a settable value.
 */
public class Cld.VChannel : Cld.AbstractChannel, Cld.ScalableChannel {

    /* Property backing fields. */
    private double _scaled_value = 0.0;
    private double _raw_value = 0.0;
    private string _taskref = null;
    private double _calculated_value = 0.0;
    private string? _expression = null;
    private string[]? _channel_names = null;

    /**
     * Calculate value if expression exists or placeholder for dummy channel.
     */
    public double raw_value {
        get { return _raw_value; }
        set {
            _raw_value = value;
            scaled_value = calibration.apply (_raw_value);
        }
    }

    /**
     * {@inheritDoc}
     */
    public virtual double scaled_value {
        get { return _scaled_value; }
        set {
            _scaled_value = value;
            new_value (id, value);
        }
    }

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

    public VChannel () {
        /* set defaults */
        set_num (0);
        this.tag = "CH0";
        this.desc = "Output Channel";
    }

    public VChannel.from_xml_node (Xml.Node *node) {
        string value;

        if (node->type == Xml.ElementType.ELEMENT_NODE &&
            node->type != Xml.ElementType.COMMENT_NODE) {
            id = node->get_prop ("id");
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
                            value = iter->get_content ();
                            set_num (int.parse (value));
                            break;
                        case "calref":
                            calref = iter->get_content ();
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
        base.set_object_property (name, object);
    }
}
