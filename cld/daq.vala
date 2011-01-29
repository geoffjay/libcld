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
using Gee;

namespace Cld {
    public class Daq : Object {
        /* property backing fields */
        private Gee.Map<string, Cld.Device> _devices;

        /* properties */
        [Property(nick = "", blurb = "")]
        public double rate { get; set; }

        [Property(nick = "", blurb = "")]
        public Gee.Map<string, Cld.Device> devices {
            get { return (_devices); }
            set { update_devices (value); }
        }

        /* constructor */
        public Daq (double rate) {
            /* instantiate object */
            Object (rate: rate);
            devices = new Gee.HashMap<string, Cld.Device> ();
        }

        public void print (FileStream f) {
            f.printf ("DAQ:\n rate - %.3f\n", rate);
            if (!devices.is_empty) {
                foreach (var dev in devices.values)
                    dev.print (f);
            }
        }

        public void update_devices (Gee.Map<string, Cld.Device> val) {
            _devices = val;
        }
    }
}
