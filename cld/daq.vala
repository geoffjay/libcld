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
 *
 * @deprecated cld-0.2.7
 */
public class Cld.Daq : Cld.AbstractContainer {

    public double rate { get; set; }

    public string driver { get; set; }

    private Gee.Map<string, Cld.Object> _objects;
    public override Gee.Map<string, Cld.Object> objects {
        get { return (_objects); }
        set { update_objects (value); }
    }

    public Daq () {
        rate = 10.0;    /* Hz */
        _objects = new Gee.TreeMap<string, Cld.Object> ();
    }

    public Daq.with_rate (double rate) {
        this.rate = rate;
        _objects = new Gee.TreeMap<string, Cld.Object> ();
    }

    /**
     * Construction using an xml node
     */
    public Daq.from_xml_node (Xml.Node *node) {
        string value;

        _objects = new Gee.TreeMap<string, Cld.Object> ();

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
                        if (iter->get_prop ("driver") == "comedi") {
                            var dev = new Cld.ComediDevice.from_xml_node (iter);
                            dev.id = iter->get_prop ("id");
                            add (dev);
                        }
                    }
                }
            }
        }
    }

    ~Daq () {
        if (_objects != null)
            _objects.clear ();
    }

    /**
     * {@inheritDoc}
     */
    public override void update_objects (Gee.Map<string, Cld.Object> val) {
        _objects = val;
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
