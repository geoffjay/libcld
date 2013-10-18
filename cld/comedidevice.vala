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
 * Authors:
 *  Geoff Johnson <geoff.jay@gmail.com>
 *  Steve Roy <sroy1966@gmail.com>
 */

using Comedi;
using Cld;

public class Cld.ComediDevice : Cld.AbstractDevice {
    /**
     * Property backing fields.
     */
    private Gee.Map<string, Object> _objects;

    /**
     * {@inheritDoc}
     */
    public override Gee.Map<string, Object> objects {
        get { return (_objects); }
        set { update_objects (value); }
    }

    /**
     * {@inheritDoc}
     */
    public override string id { get; set; }

    /**
     * {@inheritDoc}
     */
    public override int hw_type { get; set; }

    /**
     * {@inheritDoc}
     */
    public override int driver { get; set; }

    /**
     * {@inheritDoc}
     */
    public override string description { get; set; }

    /**
     * {@inheritDoc}
     */
    public override string filename { get; set; }

    /**
     * {@inheritDoc}
     */
    public override int unix_fd { get; set; }


    private bool _is_open;
    public bool is_open {
        get { return _is_open; }
        set { _is_open = value; }
    }

    /**
     * The comedi specific hardware device that this class will use.
     */
    public Comedi.Device dev;
//    public Comedi.Device dev {
//        get { return _dev; }
//    }

    /**
     * Default construction
     */
    public ComediDevice () {
        objects = new Gee.TreeMap<string, Object> ();
        id = "dev0";
        hw_type = HardwareType.INPUT;
        driver = DeviceType.COMEDI;
        filename = "/dev/comedi0";
    }

    /**
     * Construction using an xml node
     */
    public ComediDevice.from_xml_node (Xml.Node *node) {
        objects = new Gee.TreeMap<string, Object> ();
        if (node->type == Xml.ElementType.ELEMENT_NODE &&
            node->type != Xml.ElementType.COMMENT_NODE) {
            id = node->get_prop ("id");

            /* iterate through node children */
            for (Xml.Node *iter = node->children;
                 iter != null;
                 iter = iter->next) {
                if (iter->name == "property") {
                    switch (iter->get_prop ("name")) {
                        case "filename":
                            filename = iter->get_content ();
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
                else if (iter->name == "object") {
                    switch (iter->get_prop ("type")) {
                        case "task":
                            var task = new ComediTask.from_xml_node (iter);
                            add (task as Cld.Object);
                            break;
                        default:
                            break;
                    }
                }
            }
        }
    }

    /**
     * {@inheritDoc}
     */
    public override bool open () {
        dev = new Comedi.Device (filename);
        if (dev != null) {
            _is_open = true;
            return true;
        }
        else {
            _is_open = false;
            return false;
        }
    }

    /**
     * {@inheritDoc}
     */
    public override bool close () {
        if (dev.close () == 0) {
            _is_open = false;
            return true;
        }
        else
            return false;
    }


    /**
     * Retrieve information about the Comedi device.
     */
    public Information info () {
        var i = new Information ();
        i.id = id;
        i.version_code = dev.get_version_code ();
        i.driver_name = dev.get_driver_name ();
        i.board_name = dev.get_board_name ();
        i.n_subdevices = dev.get_n_subdevices ();

        return i;
    }

    /**
     * {@inheritDoc}
     */
    public override void update_objects (Gee.Map<string, Object> val) {
        _objects = val;
    }

    /**
     * {@inheritDoc}
     */
    public override void add (Object object) {
        objects.set (object.id, object);
    }

    /**
     * {@inheritDoc}
     */
    public override Object? get_object (string id) {
        Object? result = null;

        if (objects.has_key (id)) {
            result = objects.get (id);
        } else {
            foreach (var object in objects.values) {
                if (object is Container) {
                    result = (object as Container).get_object (id);
                    if (result != null) {
                        break;
                    }
                }
            }
        }

        return result;
    }


    public override string to_string () {
        string str_data = "[%s] : Comedi device using file %s\n".printf (
                            id, filename);
        /* add the hardware and driver types later */
        if (!objects.is_empty) {
            foreach (var subdev in objects.values) {
                str_data += "    %s".printf (subdev.to_string ());
            }
        }

        return str_data;
    }

    /**
     * Comedi device information class.
     */
    public class Information {

        /**
         * {@inheritDoc}
         */
        public string id { get; set; }

        public int version_code { get; set; }
        public string driver_name { get; set; }
        public string board_name { get; set; }
        public int n_subdevices { get; set; }

        public Information () {
            id = "XXXX";
            version_code = -1;
            driver_name = "XXXX";
            board_name = "XXXX";
            n_subdevices = -1;
        }

        /**
         * {@inheritDoc}
         */
        public string to_string () {
            string str_data = ("[%s] : Information for this Comedi device:\n" +
                                "   version code: %d\n" +
                                "   driver name: %s\n" +
                                "   board name: %s\n" +
                                "   n_subdevices: %d\n").printf (
                                    id, version_code, driver_name, board_name, n_subdevices);
            return str_data;
        }
    }
}
