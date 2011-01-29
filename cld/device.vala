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
    enum DeviceType {
        VIRTUAL = 0,
        COMEDI,
        MCCHID,
        ADVANTECH
    }

    public class Device : Object {
        /* properties */
        [Property(nick = "ID", blurb = "Device ID")]
        public string id { get; set; }

        [Property(nick = "Hardware Type", blurb = "Device Hardware Type")]
        public int hw_type { get; set; }

        [Property(nick = "Driver Type", blurb = "Device Driver Type")]
        public int driver_type { get; set; }

        [Property(nick = "Name", blurb = "Device Name")]
        public string name { get; set; }

        [Property(nick = "File", blurb = "Device File")]
        public string file { get; set; }

        /* constructor */
        public Device (string id,
                       int    hw_type,
                       int    driver_type,
                       string name,
                       string file) {
            Object (id:          id,
                    hw_type:     hw_type,
                    driver_type: driver_type,
                    name:        name,
                    file:        file);
        }

        public Device.with_defaults (string id) {
            Object (id: id);
            hw_type = 0;
            driver_type = 0;
            name = "device";
            file = "/dev/null";
        }

        public void print (FileStream f) {
            f.printf ("Device:\n id - %s\n hw - %d\n driver - %d\n name - %s\n file - %s\n",
                      id, hw_type, driver_type, name, file);
        }
    }
}
