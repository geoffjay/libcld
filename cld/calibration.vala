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

    /**
     * Coefficient:
     */
    public class Coefficient : Object {
        /* properties */
        public override string id    { get; set; }
        public int             n     { get; set; }
        public double          value { get; set; }

        public Coefficient (string id) {
            GLib.Object (id: id);
        }

        public Coefficient.from_xml_node (Xml.Node *node) {
            id = "";
        }

        public override string to_string () {
            string str_data = "[%s] : Coefficient\n".printf (id);
            return str_data;
        }
    }

    /**
     * Calibration:
     *
     * Perhaps not the most accurate naming here, this object represents a set
     * of coefficients used to scale a process value from a raw measurement to
     * a real life measurement such as LPM, MPH, etc.
     *
     * Calculation should be performed using the index value to determine the
     * exponent, eg. for a linear scale + offset
     *
     *   y = a[0]*x^0 + a[1]*x^1
     */
    public class Calibration : Object {
        /* property backing fields */
        private Gee.Map<int, double?> _coefficients;

        /* properties */
        public string units       { get; set; }
        public override string id { get; set; }

        /* this needs to be a map instead of a list to allow for gaps in the list */
        public Gee.Map<int, double?> coefficients {
            get { return (_coefficients); }
            set { update_coefficients (value); }
        }

        /* constructor */
        public Calibration (string units) {
            /* instantiate object */
            GLib.Object (units: units);
        }

        public Calibration.from_xml_node (Xml.Node *node) {
            id = "";
        }

        public int coefficient_count () {
            return coefficients.size;
        }

        public double nth_coefficient (int index) {
            if (!coefficients.has_key (index)) {
                throw new CalibrationError.KEY_NOT_FOUND ("The selected key/value does not exist");
            }
            return coefficients.get (index);
        }

        public void set_nth_coefficient (int index, double? val) {
            if (coefficients.has_key (index))
                coefficients.unset (index);
            coefficients.set (index, val);
        }

        public void add (int index, double? val) {
            if (coefficients.has_key (index))
                coefficients.unset (index);
            coefficients.set (index, val);
        }

        /**
         * Update property backing field for coefficients list
         *
         * @param event Array list to update property variable
         */
        private void update_coefficients (Gee.Map<int, double?> val) {
            _coefficients = val;
        }

        public void print (FileStream f) {
            /* add coefficients support */
            f.printf ("Calibration:\n units - %s\n", units);
            int i = 0;
            foreach (var c in coefficients.values) {
                f.printf (" coefficient %d - %.3f", i, c);
                i++;
            }
        }

        public override string to_string () {
            string str_data = "[%s] : y = ".printf (id);
            for (int i = 0; i < coefficients.size; i++) {
                str_data += "%.3f*x^%d".printf (coefficients.get (i), i);
                str_data += (i == coefficients.size-1) ? "" : " + ";
            }
            str_data += "\n";
            return str_data;
        }
    }
}
