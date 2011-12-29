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

    public class Filter : Object {
        /* properties */
        public override string id { get; set; }

        public Filter (string id) {
            GLib.Object (id: id);
        }

        public Filter.from_xml_node (Xml.Node *node) {
            id = "";
        }

        public override string to_string () {
            string str_data = "[%s]\n".printf (id);
            return str_data;
        }

        /**
         * dt: time gap between samples
         * fc: cutoff frequency, for our case = RC
         */
        public static void lowpass (double R, double C, double fc) {
            double dt = 0.1;
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
    }
}
