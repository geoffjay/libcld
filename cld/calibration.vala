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
    public class Calibration : Object {
        /* properties */
        [Property(nick = "", blurb = "")]
        public Gee.LinkedList<double?> coefficients { get; set; }

        [Property(nick = "", blurb = "")]
        public string units { get; set; }

        /* constructor */
        public Calibration (string units) {
            /* instantiate object */
            Object (units: units);
        }

        public int coefficient_count () {
            return coefficients.size;
        }

        public double nth_coefficient (int n) {
            return coefficients.get (n);
        }

        public void set_nth_coefficient (int n, double val) {
            coefficients.set (n, val);
        }

        public void add (double val) {
            coefficients.add (val);
        }

        public void print (FileStream f) {
            /* add coefficients support */
            f.printf ("Calibration:\n units - %s\n", units);
            int i = 0;
            foreach (var c in coefficients) {
                f.printf (" coefficient %d - %.3f", i, c);
                i++;
            }
        }
    }
}
