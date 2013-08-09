/**
 * Copyright (C) 2010 Geoff Johnson, Scott Hazlett
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
 *  Scott Hazlett <scott.hazlett@gmail.com>
 */

/*
   For acceptable expression syntax, see the online reference for libmatheval.
http://www.gnu.org/software/libmatheval/manual/libmatheval.html#evaluator_005fcreate
 */

using Cld;
using matheval;

class Cld.MathEvalExample: GLib.Object {

    public void run () {
        var builder = new Builder.from_file ("matheval.xml");
        /*Create 4 dummy input channels defined in xml*/
        var ai0 = builder.get_object ("ai0");
        message ("%s\n", ai0.to_string ());
        var ai1 = builder.get_object ("ai1");
        var ai2 = builder.get_object ("ai2");
        var ai3 = builder.get_object ("ai3");

        /*Create 1 Virtual channel defined in xml*/
        var vc = builder.get_object ("vc0");

        double[,] SAMPLE_DATA = {
            {21.0, 16.0, 22.0, 21.0},
            {1.678e34, 1024.0*1024.0, 1.404e34, 6.09e33},
            {-5.0, 7.0*7.0, -6.543, -4.343},
            {0.0, 0.0, 0.0, 0.0}
        };

        /*-------------------------------------------------------------------*/
        /* Test expression of vchannel which is average of 4 channels*/
        /* Calculate the expected result, and compare to vchannel result */
        for (var i = 0; i < SAMPLE_DATA.length[0]; i++) {

            (ai0 as AIChannel).raw_value = SAMPLE_DATA[ i, 0 ];
            (ai1 as AIChannel).raw_value = SAMPLE_DATA[ i, 1 ];
            (ai2 as AIChannel).raw_value = SAMPLE_DATA[ i, 2 ];
            (ai3 as AIChannel).raw_value = SAMPLE_DATA[ i, 3 ];

            double expected = (
                    SAMPLE_DATA[ i, 0 ]+
                    SAMPLE_DATA[ i, 1 ]+
                    SAMPLE_DATA[ i, 2 ]+
                    SAMPLE_DATA[ i, 3 ]
                    ) / 4;

            stdout.printf("Evaluating %s\n", (vc as VChannel).expression);
            if (expected == (vc as VChannel).calculated_value) {
                stdout.printf("    PASS %s returned %lf\n",
                        (vc as VChannel).expression,
                        (vc as VChannel).calculated_value);
            } else {
                stdout.printf("*** FAIL %s returned %lf but expected %lf\n",
                        (vc as VChannel).expression,
                        (vc as VChannel).calculated_value,
                        expected);
            }
        }
    }

    public static int main (string[] main) {
        Xml.Parser.init ();
        MathEvalExample ex = new MathEvalExample ();
        ex.run ();
        Xml.Parser.cleanup ();

        return 0;
    }
}

