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
 * Hardware definition class.
 */
public class Cld.Daq : AbstractContainer {

    /* properties */
    public override string id   { get; set; }
    public double rate          { get; set; }
    public string driver        { get; set; }

    private Gee.Map<string, Object> _objects;
    public override Gee.Map<string, Object> objects {
        get { return (_objects); }
        set { update_objects (value); }
    }

    public Daq () {
        rate = 10.0;    /* Hz */
        objects = new Gee.TreeMap<string, Object> ();
    }

    public Daq.with_rate (double rate) {
        this.rate = rate;
        objects = new Gee.TreeMap<string, Object> ();
    }

    /**
     * Construction using an xml node
     */
//    public Daq.from_xml_node (Xml.Node *node) {
//        string value;
//
//        objects = new Gee.TreeMap<string, Object> ();
//
//        if (node->type == Xml.ElementType.ELEMENT_NODE &&
//            node->type != Xml.ElementType.COMMENT_NODE) {
//            id = node->get_prop ("id");
//            driver = node->get_prop ("driver");
//            /* iterate through node children */
//            for (Xml.Node *iter = node->children; iter != null; iter = iter->next) {
//                if (iter->name == "property") {
//                    switch (iter->get_prop ("name")) {
//                        case "rate":
//                            value = iter->get_content ();
//                            rate = double.parse (value);
//                            break;
//                        default:
//                            break;
//                    }
//                } else if (iter->name == "object") {
//                    if (iter->get_prop ("type") == "device") {
//                        var dev = new Device.from_xml_node (iter);
//                        objects.set (dev.id, dev);
//                    }
//                }
//            }
//        }
//    }
//
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

    /**
     * {@inheritDoc}
     */
    public override string to_string () {
        string str_data = "[%s] : DAQ with rate %.3f\n".printf (id, rate);
        /* copy the device print iteration here later in testing */
        if (!objects.is_empty) {
            foreach (var dev in objects.values)
                str_data += "  %s".printf (dev.to_string ());
        }
        return str_data;
    }
}
