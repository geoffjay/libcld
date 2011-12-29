/**
 * Copyright (C) 2010 Geoff Johnson <geoff.jay@gmail.com>
 *
 * This file is part of libcld.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
 */

namespace Cld {
    public abstract class Channel : Object {
        /* inherited properties */
        public override string id     { get; set; }

        /* inheritable properties */
        public abstract int num       { get; set; }
        public abstract string devref { get; set; }
        public abstract string tag    { get; set; }
        public abstract string desc   { get; set; }
        public abstract int existence { get; set; }

        /* constructor - not necessary in abstract class, remove */
        public Channel (int    num,
                        string id,
                        string tag,
                        string desc,
                        int existence) {
            /* instantiate new object */
            GLib.Object (num:    num,
                         id:     id,
                         tag:    tag,
                         desc:   desc,
                         existence: existence);
        }

        public Channel.with_devref (int    num,
                                    string id,
                                    string devref,
                                    string tag,
                                    string desc,
                                    int existence) {
            /* instantiate new object */
            GLib.Object (num:    num,
                         id:     id,
                         devref: devref,
                         tag:    tag,
                         desc:   desc,
                         existence: existence);
        }
    }

    /**
     * AChannel:
     *
     * Analog channel interface class.
     */
    public interface AChannel : Object, Channel {
        public abstract Calibration cal     { get; set; }
        public abstract double value        { get; set; }
        public abstract double scaled_value { get; set; }
        public abstract double avg_value    { get; set; }
    }

    /**
     * DChannel:
     *
     * Digital channel interface class.
     */
    public interface DChannel : Object, Channel {
    }

    /**
     * IChannel:
     *
     * Input channel interface class, I is for input not interface.
     */
    public interface IChannel : Object, Channel {
    }

    /**
     * OChannel:
     *
     * Output channel interface class.
     */
    public interface OChannel : Object, Channel {
    }

    /**
     * AIChannel:
     *
     * Analog input channel class.
     */
    public class AIChannel : Object, Channel, AChannel, IChannel {
        /* properties - from Object */
        public override string id { get; set; }
        /* properties - from AChannel */
        public override Calibration cal { get; set; }
        public override double value { get; set; }
        public override double scaled_value { get; set; }
        public override double avg_value { get; set; }
        /* properties */
        public double slope { get; set; }
        public double yint  { get; set; }
        public string units { get; set; }
        public string color { get; set; }
        public int raw_value_list_size { get; set; }    /* this is redundant */

        public Gee.LinkedList<double?> raw_value_list;

        /* default constructor */
        public AIChannel (string id, string tag, string desc,
                          int num, double slope, double yint,
                          string units, string color) {
            base (num, id, tag, desc, 0);
            this.slope = slope;
            this.yint = yint;
            this.units = units;
            this.color = color;
            raw_value_list = new Gee.LinkedList<double?> ();
            raw_value_list_size = 0;
        }

        public AIChannel.from_xml_node (Xml.Node *node) {
            id = "";
        }

        public void add_raw_value (double value) {
            double conv = value;
            /* clip the input */
            conv = (conv <  0.0) ?  0.0 : conv;
            conv = (conv > 10.0) ? 10.0 : conv;
            conv = (conv / 10.0) * 65535.0;  /* assume 0-10V range */

//            raw_value_list.insert (0, conv);
            raw_value_list.add (conv);
            if (raw_value_list.size > raw_value_list_size) {
//                conv = raw_value_list.poll_tail ();
                conv = raw_value_list.poll_head ();
            }
        }

        public void update_avg_value () {
            double sum = 0.0;

            if (raw_value_list.size > 0) {
                foreach (double value in raw_value_list) {
                    /* !!! for now assume 16 bit with 0-10V range - fix later */
//                    value = ((value / 65535.0) * 10.0) * slope + yint;
                    value = (value / 65535.0) * 10.0;
                    sum += value;
                }

                avg_value = sum / raw_value_list.size;
//                stdout.printf ("AVG: %10.3f :: %d :: %10.3f\n", sum, raw_value_list.size, avg_value);
            }
        }

        public void print (FileStream f) {
            f.printf ("AnalogInputChannel:\n id - %s\n tag - %s\n desc - %s\n num - %d\n slope - %.3f\n yint - %.3f\n units - %s\n color - %s\n",
                      id, tag, desc, num, slope, yint, units, color);
        }

        public override string to_string () {
            string str_data = "[%s]\n".printf (id);
            return str_data;
        }
    }

    /**
     * AOChannel:
     *
     * Analog output channel class.
     */
    public class AOChannel : Object, Channel, AChannel, OChannel {
        /* properties */
        public override string id           { get; set; }
        public override double value        { get; set; }
        public override double scaled_value { get; set; }
        public override double avg_value    { get; set; }
        public bool manual                  { get; set; }

        /* default constructor */
        public AOChannel (int    num,
                          string id,
                          string tag,
                          string desc,
                          int    existence) {
            /* pass on to base class constructor */
            base (num, id, tag, desc, existence);
            value = 0.0;
        }

        public AOChannel.from_xml_node (Xml.Node *node) {
            id = "";
        }

        public void print (FileStream f) {
            f.printf ("AnalogOutputChannel:\n id - %s\n tag - %s\n desc - %s\n num - %d\n",
                      id, tag, desc, num);
        }

        public override string to_string () {
            string str_data = "[%s]\n".printf (id);
            return str_data;
        }
    }

    /**
     * DIChannel:
     *
     * Digital input channel class.
     */
    public class DIChannel : Object, Channel, DChannel, IChannel {
        /* properties */
        public override string id { get; set; }
        public bool state { get; set; }

        /* default constructor */
        public DIChannel (int    num,
                          string id,
                          string tag,
                          string desc,
                          int    existence) {
            /* pass on to base class constructor */
            base (num, id, tag, desc, existence);
            state = false;
        }

        public DIChannel.from_xml_node (Xml.Node *node) {
            id = "";
        }

        public override string to_string () {
            string str_data = "[%s]\n".printf (id);
            return str_data;
        }
    }

    /**
     * DOChannel:
     *
     * Digital output channel class.
     */
    public class DOChannel : Channel {
        /* properties */
        public override string id { get; set; }
        public bool state { get; set; }

        /* default constructor */
        public DOChannel (int    num,
                          string id,
                          string tag,
                          string desc,
                          int    existence) {
            /* pass on to base class constructor */
            base (num, id, tag, desc, existence);
            state = false;
        }

        public DOChannel.from_xml_node (Xml.Node *node) {
            id = "";
        }

        public override string to_string () {
            string str_data = "[%s]\n".printf (id);
            return str_data;
        }
    }
}
