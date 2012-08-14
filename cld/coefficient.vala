/**
 * Copyright (C) 2010 Geoff Johnson <geoff.jay@gmail.com>
 *
 * This file is part of libcld.
 *
 * libcld is free software; you can redistribute it and/or modify
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

public class Cld.Coefficient : AbstractObject {
    /* properties */
    public override string id    { get; set; }
    public int             n     { get; set; }
    public double          value { get; set; }

    public Coefficient () {
        id = "cft0";
        n = 0;
        value = 0.0;
    }

    public Coefficient.with_id (string id) {
        GLib.Object (id: id);
        /* defaults */
        n = 0;
        value = 0.0;
    }

    public Coefficient.from_xml_node (Xml.Node *node) {
        string val;

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
                        case "n":
                            val = iter->get_content ();
                            n = int.parse (val);
                            break;
                        case "value":
                            val = iter->get_content ();
                            value = double.parse (val);
                            break;
                        default:
                            break;
                    }
                }
            }
        }
    }

    public override string to_string () {
        string str_data  = "[%s] : Coefficient\n".printf (id);
               str_data += "\tn: %d\n\tvalue: %f\n".printf (n, value);
        return str_data;
    }
}
