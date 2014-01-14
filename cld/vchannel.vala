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
 * Virtual channel to be used to execute expressions or just as a dummy channel
 * with a settable value.
 */
public class Cld.VChannel : AbstractChannel, ScalableChannel {

    /**
     * {@inheritDoc}
     */
    public override string id { get; set; }

    /**
     * {@inheritDoc}
     */
    public override int num { get; set; }

    /**
     * {@inheritDoc}
     */
    public override int subdevnum {get; set; }

    /**
     * {@inheritDoc}
     */
    public override string devref { get; set; }

    /**
     * {@inheritDoc}
     */
    public override weak Device device { get; set; }

    /**
     * {@inheritDoc}
     */
    public override string taskref { get {
                                        if (_taskref == null)
                                            throw new Cld.Error.NULL_REF ("A taskref has not been set for this virtual channel.");
                                        else
                                            return _taskref;}
                                    set {_taskref = value; }}

    /**
     * {@inheritdoc}
     */
    public override weak Task task { get; set; }

    /**
     * {@inheritDoc}
     */
    public override string tag { get; set; }

    /**
     * {@inheritDoc}
     */
    public override string desc { get; set; }

    /**
     * Mathematical expression to be used to evaluate the channel value.
     */
    public string expression { get; set; }

    /* Property backing fields. */
    private double _scaled_value = 0.0;
    private double _raw_value = 0.0;

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
        private set {
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
    public virtual weak Calibration calibration { get; set; }

    /**
     * {@inheritDoc}
     */
    //public override signal void new_value ();

    /* default constructor */
    public VChannel () {
        /* set defaults */
        this.num = 0;
        this.devref = "dev0";
        this.tag = "CH0";
        this.desc = "Output Channel";
    }

    public VChannel.from_xml_node (Xml.Node *node) {
        string value;

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
                        case "expression":
                            expression = iter->get_content ();
                            break;
                        case "num":
                            value = iter->get_content ();
                            num = int.parse (value);
                            break;
                        case "calref":
                            calref = iter->get_content ();
                            break;
                        case "taskref":
                           /* this should maybe be an object property,
                             * possibly fix later */
                            taskref = iter->get_content ();
                            break;
                        case "devref":
                            devref = iter->get_content ();
                            break;
                        default:
                            break;
                    }
                }
            }
        }
    }

    public override string to_string () {
        return base.to_string ();
    }
}
