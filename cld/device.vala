/**
 * Copyright (C) 2010 Geoff Johnson
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
 */

/**
 * Hardware device information and settings.
 */
public class Cld.Device : AbstractObject {
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

    /**
     * Default construction
     */
    public Device () {
        id = "dev0";
        hw_type = 0;
        driver = 0;
        name = "device";
        file = "/dev/null";
    }

    /**
     * Construction using an xml node
     */
    public Device.from_xml_node (Xml.Node *node) {

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

    public override string to_string () {
        string str_data = "[%s] : Device %s with file %s\n".printf (
                            id, name, file);
        /* add the hardware and driver types later */
        return str_data;
    }
}
