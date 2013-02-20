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
public class Cld.AIChannel : AbstractChannel, AChannel, IChannel {

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
    public override string devref { get; set; }

    /**
     * {@inheritDoc}
     */
    public override weak Device device { get; set; }

    /**
     * {@inheritDoc}
     */
    public override string tag { get; set; }

    /**
     * {@inheritDoc}
     */
    public override string desc { get; set; }

    /**
     * {@inheritDoc}
     */
    public virtual string calref { get; set; }

    /**
     * {@inheritDoc}
     */
    public virtual weak Calibration calibration { get; set; }

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
    public virtual double raw_value {
        get {
            return _raw_value[0];
        }
        /* XXX consider getting rid of the call to add_raw_value to pack it
               onto the list and just use this setter */
        set {
            _raw_value[2] = _raw_value[1];
            _raw_value[1] = _raw_value[0];
            _raw_value[0] = value;
        }
    }

    /**
     * {@inheritDoc}
     */
    public virtual double avg_value {
        get {
            double sum = 0.0;

            if (raw_value_list.size > 0) {
                foreach (double value in raw_value_list) {
                    /* XXX for now assume 16 bit with 0-10V range, fix later */
                    value = (value / 65535.0) * 10.0;
                    sum += value;
                }

                avg_value = sum / raw_value_list.size;
            }
            return _avg_value[0];
        }
        set {
            _avg_value[2] = _avg_value[1];
            _avg_value[1] = _avg_value[0];
            _avg_value[0] = value;
        }
    }

    /**
     * {@inheritDoc}
     */
    public virtual double scaled_value {
        get {
            scaled_value = calibration.apply (avg_value);
            return _scaled_value[0];
        }
        set {
            _scaled_value[2] = _scaled_value[1];
            _scaled_value[1] = _scaled_value[0];
            _scaled_value[0] = value;
        }
    }

    /**
     * Read only previous scaled value, used with control loops and filters.
     * XXX Consider name change.
     */
    public double pr_scaled_value { get { return _scaled_value[1]; } }

    /**
     * Read only previous previous scaled value, used with control loops and
     * filters.
     * XXX Consider name change.
     */
    public double ppr_scaled_value { get { return _scaled_value[2]; } }

    public int raw_value_list_size { get; set; }    /* redundant ? */

    private Gee.LinkedList<double?> raw_value_list;

    /* default constructor */
    public AIChannel () {
        /* set defaults */
        this.num = 0;
        this.devref = "dev0";
        this.tag = "CH0";
        this.desc = "Input Channel";

        /* create list for raw data */
        raw_value_list = new Gee.LinkedList<double?> ();
        raw_value_list_size = 0;
    }

    public AIChannel.from_xml_node (Xml.Node *node) {
        string val;

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
                        case "calref":
                            /* this should maybe be an object property,
                             * possibly fix later */
                            calref = iter->get_content ();
                            break;
                        default:
                            break;
                    }
                }
            }
        }

        /* create list for raw data */
        raw_value_list = new Gee.LinkedList<double?> ();
    }

    public void add_raw_value (double value) {
        double conv = value;
        /* clip the input */
        conv = (conv <  0.0) ?  0.0 : conv;
        conv = (conv > 10.0) ? 10.0 : conv;
        conv = (conv / 10.0) * 65535.0;  /* assume 0-10V range */

        /* for now add it to the list and the raw value array */
        raw_value_list.add (conv);
        raw_value = conv;

        if (raw_value_list.size > raw_value_list_size) {
            /* throw away the value */
            conv = raw_value_list.poll_head ();
        }
    }

    public void update_avg_value () {
        double sum = 0.0;

        if (raw_value_list.size > 0) {
            foreach (double value in raw_value_list) {
                /* !!! for now assume 16 bit with 0-10V range - fix later */
//                value = ((value / 65535.0) * 10.0) * slope + yint;
                value = (value / 65535.0) * 10.0;
                sum += value;
            }

            avg_value = sum / raw_value_list.size;
        }
    }

    /**
     * {@inheritDoc}
     */
    public override string to_string () {
        return base.to_string ();
    }
}
