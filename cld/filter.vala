/**
 * libcld
 * Copyright (c) 2014, Geoff Johnson, All rights reserved.
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
 * Filter class for digital signal processing.
 */
public class Cld.Filter : AbstractObject {

    public Filter () {
        id = "flt0";
    }

    public Filter.from_xml_node (Xml.Node *node) {
        id = "";
    }

    /**
     * dt: time gap between samples
     * fc: cutoff frequency, for our case = RC
     */
    public static void low_pass (double R, double C, double fc) {
        /*
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
                stdout.printf ("%f, ", y);
            }
            stdout.printf ("\n");
        }
        */
    }
}
