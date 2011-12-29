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

using Gee;

namespace Cld {

    public class Device : Object {
        /* properties */
        [Property(nick = "ID", blurb = "Device ID")]
        public override string id { get; set; }

        [Property(nick = "Hardware Type", blurb = "Device Hardware Type")]
        public int hw_type { get; set; }

        [Property(nick = "Driver Type", blurb = "Device Driver Type")]
        public int driver { get; set; }

        [Property(nick = "Name", blurb = "Device Name")]
        public string name { get; set; }

        [Property(nick = "File", blurb = "Device File")]
        public string file { get; set; }

        /* constructor */
        public Device (string id,
                       int    hw_type,
                       int    driver,
                       string name,
                       string file) {
            GLib.Object (id:      id,
                         hw_type: hw_type,
                         driver:  driver,
                         name:    name,
                         file:    file);
        }

        public Device.with_defaults (string id) {
            GLib.Object (id: id);

            hw_type = 0;
            driver = 0;
            name = "device";
            file = "/dev/null";
        }

        /**
         * Construction using an xml node
         */
        public Device.from_xml_node (Xml.Node *node) {
            id = "";
            hw_type = 0;
            driver = 0;
            name = "";
            file = "";

            if (node->type == Xml.ElementType.ELEMENT_NODE &&
                node->type != Xml.ElementType.COMMENT_NODE) {
                id = node->get_prop ("id");
                var dt = node->get_prop ("driver");
                if (dt == "virtual")
                    driver = DeviceType.VIRTUAL;
                else if (dt == "comedi")
                    driver = DeviceType.COMEDI;
                else if (dt == "mcchid")
                    driver = DeviceType.MCCHID;
                else if (dt == "advantech")
                    driver = DeviceType.ADVANTECH;

                /* iterate through node children */
                for (Xml.Node *iter = node->children;
                     iter != null;
                     iter = iter->next) {
                    if (iter->name == "property") {
                        switch (iter->get_prop ("name")) {
                            case "hardware":
                                name = iter->get_content ();
                                break;
                            case "file":
                                file = iter->get_content ();
                                break;
                            case "type":
                                var type = iter->get_content ();
                                if (type == "input")
                                    hw_type = HardwareType.INPUT;
                                else if (type == "output")
                                    hw_type = HardwareType.OUTPUT;
                                else if (type == "counter")
                                    hw_type = HardwareType.COUNTER;
                                else if (type == "multifunction")
                                    hw_type = HardwareType.MULTIFUNCTION;
                                break;
                            default:
                                break;
                        }
                    }
                }
            }
        }

        public void print (FileStream f) {
            f.printf ("Device:\n id - %s\n hw - %d\n driver - %d\n "
                      "name - %s\n file - %s\n",
                      id, hw_type, driver, name, file);
        }

        public override string to_string () {
            string str_data = "[%s] : Device %s with file %s\n".printf (id,
                                    name, file);
            /* add the hardware and driver types later */
            return str_data;
        }
    }
}
