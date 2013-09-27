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
public class Cld.AIChannel : AbstractChannel, AChannel, IChannel, ScalableChannel {

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
    public override string taskref { get; set; }

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
     * {@inheritDoc}
     */
    public virtual string calref { get; set; }

    /**
     * {@inheritDoc}
     */
    public virtual weak Calibration calibration { get; set; }

    /**
     * {@inheritdoc}
     */
    public virtual int range { get; set; }

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
            new_value (value);
        }
    }

    /**
     * Read only current unaveraged value, used with control loops and filters.
     * XXX consider name change
     */
    public double current_value {
        get {
            double value;
            lock (raw_value_list) {
                value = calibration.apply (raw_value_list.get (raw_value_list.size - 1));
            }
            return value;
        }
    }

    /**
     * Read only previous unaveraged value, used with control loops and filters.
     * XXX consider name change
     */
    public double previous_value {
        get {
            double value;
            lock (raw_value_list) {
                value = calibration.apply (raw_value_list.get (raw_value_list.size - 2));
            }
            return value;
        }
    }

    /**
     * Read only previous previous unaveraged value, used with control loops and
     * filters.
     * XXX consider name change
     */
    public double past_previous_value {
        get {
            double value;
            lock (raw_value_list) {
                value = calibration.apply (raw_value_list.get (raw_value_list.size - 3));
            }
            return value;
        }
    }

    /**
     * Controls the size of the list that holds raw values and is used as the
     * size of the window for the moving average.
     *
     * XXX should be max list size, naming is confusing
     * XXX if value != current the list should be resized to reflect the change
     * XXX having a minimum size of 3 isn't ideal, instead the getters on the
     *     values that index the list size should check there and handle
     *     appropriately
     */
    private int _raw_value_list_size = 3;
    public int raw_value_list_size {
        get { return _raw_value_list_size; }
        set {
            if (value < 3)
                _raw_value_list_size = 3;
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
    }

    /**
     * Alternate construction that uses an XML node to set the object up.
     */
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
                        case "naverage":
                            val = iter->get_content ();
                            raw_value_list_size = int.parse (val);
                            break;
                        case "calref":
                            /* this should maybe be an object property,
                             * possibly fix later */
                            calref = iter->get_content ();
                            break;
                        case "taskref":
                           /* this should maybe be an object property,
                             * possibly fix later */
                            taskref = iter->get_content ();
                            break;
                        case "range":
                            val = iter->get_content ();
                            range = int.parse (val);
                            break;
                        default:
                            break;
                    }
                }
            }
        }

        preload_raw_value_list ();
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
            var sum = 0.0;
            if (raw_value_list.size > 0) {
                foreach (var datum in raw_value_list) {
                    sum += datum;
                }

                avg_value = sum / raw_value_list.size;
            }
        }

        /* update the scaled value */
        scaled_value = calibration.apply (avg_value);
    }

    /**
     * Update the value for the running average that represents the contents
     * of the raw data list.
     *
     * @deprecated The getter for avg_value performs the same functionality.
     */
    public void update_avg_value () {
        double sum = 0.0;

        if (raw_value_list.size > 0) {
            foreach (double value in raw_value_list) {
                sum += value;
            }

            avg_value = sum / raw_value_list.size;
        }
    }

    /**
     * {@inheritDoc}
     */
    public override string to_string () {
        return base.to_string () + " [range]: %d\n".printf (range);
;
    }
}
