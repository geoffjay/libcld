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
    public class Pid : Object {
        /* properties */
        [Property(nick = "ID", blurb = "PID ID")]
        public string id { get; set; }

        [Property(nick = "Kp", blurb = "PID Kp Value")]
        public double kp { get; set; }

        [Property(nick = "Ki", blurb = "PID Ki Value")]
        public double ki { get; set; }

        [Property(nick = "Kd", blurb = "PID Kd Value")]
        public double kd { get; set; }

        [Property(nick = "SP", blurb = "PID Set Point Value")]
        public double sp { get; set; }

        [Property(nick = "P Error", blurb = "PID Proportional Gain Error")]
        public double p_err { get; set; }

        [Property(nick = "I Error", blurb = "PID Integral Gain Error")]
        public double i_err { get; set; }

        [Property(nick = "D Error", blurb = "PID Differential Gain Error")]
        public double d_err { get; set; }

        /* constructor */
        public Pid (string id,
                    double sp,
                    double kp,
                    double ki,
                    double kd,
                    double p_err = 0.0,
                    double i_err = 0.0,
                    double d_err = 0.0) {
            /* instantiate object */
            Object (id:    id,
                    sp:    sp,
                    kp:    kp,
                    ki:    ki,
                    kd:    kd,
                    p_err: p_err,
                    i_err: i_err,
                    d_err: d_err);
        }

        public void print (FileStream f) {
            f.printf ("PID:\n id - %s\n sp - %.3f\n kp - %.3f\n ki - %.3f\n kd - %.3f\n",
                      id, sp, kp, ki, kd);
        }
    }
}
