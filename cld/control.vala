/**
 * Copyright (C) 2010 Geoff Johnson <geoff.jay@gmail.com>
 *
 * This file is part of libcld.
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
 */

public class Cld.ProcessValue : AbstractObject {
    /* properties */
    public override string id { get; set; }
    public string chref       { get; set; }

    /* constructor */
    public ProcessValue (string id, string chref) {
        GLib.Object (id:    id,
                     chref: chref);
    }

    public ProcessValue.from_xml_node (Xml.Node *node) {
        if (node->type == Xml.ElementType.ELEMENT_NODE &&
            node->type != Xml.ElementType.COMMENT_NODE) {
            id = node->get_prop ("id");
            chref = node->get_prop ("chref");
        }
    }

    public override string to_string () {
        string str_data = "[%s] : Process value with channel reference %s\n".printf (id, chref);
        return str_data;
    }
}

public class Cld.Control : AbstractObject {
    /* property backing fields
     * - using a backing field is carryover from another library where
     *   performing a refresh was required on update so this may not be
     *   necessary anymore, review later */
    private Gee.Map<string, Object> _objects;

    /* properties */
    public override string id { get; set; }

    public Gee.Map<string, Object> objects {
        get { return (_objects); }
        set { update_objects (value); }
    }

    /* constructor */
    public Control (string id) {
        /* instantiate object */
        GLib.Object (id: id);

        objects = new Gee.TreeMap<string, Object> ();
    }

    public Control.from_xml_node (Xml.Node *node) {
        objects = new Gee.TreeMap<string, Object> ();

        if (node->type == Xml.ElementType.ELEMENT_NODE &&
            node->type != Xml.ElementType.COMMENT_NODE) {
            id = node->get_prop ("id");
            /* iterate through node children */
            for (Xml.Node *iter = node->children;
                 iter != null;
                 iter = iter->next) {
                if (iter->name == "property") {
                    /* no defined properties yet */
                    switch (iter->get_prop ("name")) {
                        default:
                            break;
                    }
                } else if (iter->name == "object") {
                    if (iter->get_prop ("type") == "pid") {
                        var pid = new Pid.from_xml_node (iter);
                        objects.set (pid.id, pid);
                    }
                }
            }
        }
    }

    public void update_objects (Gee.Map<string, Object> val) {
        _objects = val;
    }

    public override string to_string () {
        string str_data = "[%s] : Control object\n".printf (id);
        return str_data;
    }
}
