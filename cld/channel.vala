/*
** Copyright (C) 2010 Geoff Johnson <geoff.jay@gmail.com>
**
** This program is free software; you can redistribute it and/or modify
** it under the terms of the GNU General Public License as published by
** the Free Software Foundation; either version 2 of the License, or
** (at your option) any later version.
**
** This program is distributed in the hope that it will be useful,
** but WITHOUT ANY WARRANTY; without even the implied warranty of
** MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
** GNU General Public License for more details.
**
** You should have received a copy of the GNU General Public License
** along with this program; if not, write to the Free Software
** Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
*/

using GLib;

namespace Cld {
    public class Channel : Object {
        /* properties */
        [Property(nick = "Number", blurb = "Number")]
        public int num       { get; set; }

        [Property(nick = "ID", blurb = "ID")]
        public string id     { get; set; }

        [Property(nick = "Device reference ID", blurb = "Device reference ID")]
        public string devref { get; set; }

        [Property(nick = "Tag", blurb = "Tag")]
        public string tag    { get; set; }

        [Property(nick = "Description", blurb = "Description")]
        public string desc   { get; set; }

        [Property(nick = "Existence", blurb = "Existence")]
        public int existence { get; set; }

        /* constructor */
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

    /* analog input */
    public class AnalogInputChannel : Channel {
        /* properties */
//        [Property(nick = "", blurb = "")]
//        public Calibration cal { get; set; }

//--
        [Property(nick = "", blurb = "")]
        public double slope { get; set; }

        [Property(nick = "", blurb = "")]
        public double yint { get; set; }

        [Property(nick = "", blurb = "")]
        public string units { get; set; }

        [Property(nick = "", blurb = "")]
        public string color { get; set; }
//--

        [Property(nick = "", blurb = "")]
        public double value { get; set; }

        [Property(nick = "", blurb = "")]
        public double scaled_value { get; set; }

        [Property(nick = "", blurb = "")]
        public double avg_value { get; set; }

        [Property(nick = "", blurb = "")]
        public int raw_value_list_size { get; set; }

        public Gee.LinkedList<double?> raw_value_list;

        /* default constructor */
//        public AnalogInputChannel (int         num,
//                                   string      id,
//                                   string      tag,
//                                   string      desc,
//                                   int         existence,
//                                   Calibration cal) {
            /* pass on to base class constructor */
//            base (num, id, tag, desc, existence);
//            this.cal = cal;
//            value = 0.0;
//            scaled_value  = 0.0;
//        }

        public AnalogInputChannel (string id, string tag, string desc, int num, double slope, double yint, string units, string color) {
            base (num, id, tag, desc, 0);
            this.slope = slope;
            this.yint = yint;
            this.units = units;
            this.color = color;
            raw_value_list = new Gee.LinkedList<double?> ();
            raw_value_list_size = 0;
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

        /**
         * dt: time gap between samples
         * fc: cutoff frequency, for our case = RC
         */
        public void lowpass (double R, double C, double fc) {
            double a = dt / (dt + fc);
            double yc, yp, y;

            if (raw_value_list.size > 0) {
                stdout.printf ("CH%d: ", num);
                for (int i = raw_value_list.size - 2; i >= 0; i--) {
                    yc = raw_value_list.get (i);
                    yp = raw_value_list.get (i+1);
                    y = a * yc + ((1-a) * yp);
                    raw_value_list.set (i, y);
                    stdout.printf ("%f, ", y);//raw_value_list.get (i-1));
                }
                stdout.printf ("\n");
            }
        }

        public void print (FileStream f) {
            f.printf ("AnalogInputChannel:\n id - %s\n tag - %s\n desc - %s\n num - %d\n slope - %.3f\n yint - %.3f\n units - %s\n color - %s\n",
                      id, tag, desc, num, slope, yint, units, color);
        }
    }

    /* analog output */
    public class AnalogOutputChannel : Channel {
        /* properties */
        [Property(nick = "", blurb = "")]
        public double value { get; set; }

        [Property(nick = "", blurb = "")]
        public bool manual { get; set; }

        /* default constructor */
        public AnalogOutputChannel (int    num,
                                    string id,
                                    string tag,
                                    string desc,
                                    int    existence) {
            /* pass on to base class constructor */
            base (num, id, tag, desc, existence);
            value = 0.0;
        }

        public void print (FileStream f) {
            f.printf ("AnalogOutputChannel:\n id - %s\n tag - %s\n desc - %s\n num - %d\n",
                      id, tag, desc, num);
        }
    }

    /* digital input */
    public class DigitalInputChannel : Channel {
        /* properties */
        [Property(nick = "", blurb = "")]
        public bool state { get; set; }

        /* default constructor */
        public DigitalInputChannel (int    num,
                                    string id,
                                    string tag,
                                    string desc,
                                    int    existence) {
            /* pass on to base class constructor */
            base (num, id, tag, desc, existence);
            state = false;
        }
    }

    /* digital output */
    public class DigitalOutputChannel : Channel {
        /* properties */
        [Property(nick = "", blurb = "")]
        public bool state { get; set; }

        /* default constructor */
        public DigitalOutputChannel (int    num,
                                     string id,
                                     string tag,
                                     string desc,
                                     int    existence) {
            /* pass on to base class constructor */
            base (num, id, tag, desc, existence);
            state = false;
        }
    }
}
