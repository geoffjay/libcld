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
    public class Daq : Object {
        /* property backing fields */
        private Gee.Map<string, Cld.Object> _devices;

        /* properties */
        public override string id   { get; set; }
        public double rate          { get; set; }
        public string driver        { get; set; }

        public Gee.Map<string, Cld.Object> devices {
            get { return (_devices); }
            set { update_devices (value); }
        }

        /* constructor */
        public Daq (double rate) {
            /* instantiate object */
            GLib.Object (rate: rate);
            devices = new Gee.TreeMap<string, Cld.Object> ();
        }

        /**
         * Construction using an xml node
         */
        public Daq.from_xml_node (Xml.Node *node) {
            string value;

            devices = new Gee.TreeMap<string, Cld.Object> ();

            if (node->type == Xml.ElementType.ELEMENT_NODE &&
                node->type != Xml.ElementType.COMMENT_NODE) {
                id = node->get_prop ("id");
                driver = node->get_prop ("driver");
                /* iterate through node children */
                for (Xml.Node *iter = node->children; iter != null; iter = iter->next) {
                    if (iter->name == "property") {
                        switch (iter->get_prop ("name")) {
                            case "rate":
                                value = iter->get_content ();
                                rate = double.parse (value);
                                break;
                            default:
                                break;
                        }
                    } else if (iter->name == "object") {
                        if (iter->get_prop ("type") == "device") {
                            var dev = new Device.from_xml_node (iter);
                            devices.set (dev.id, dev);
                        }
                    }
                }
            }
        }

        public void update_devices (Gee.Map<string, Cld.Object> val) {
            _devices = val;
        }

        public override string to_string () {
            string str_data = "[%s] : DAQ with rate %.3f\n".printf (id, rate);
            /* copy the device print iteration here later in testing */
            if (!devices.is_empty) {
                foreach (var dev in devices.values)
                    str_data += "  %s".printf (dev.to_string ());
            }
            return str_data;
        }
    }
}
