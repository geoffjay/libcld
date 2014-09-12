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
 *  Stepehen Roy <sroy1966@gmail.com>
 */

/**
 * A class with methods for managing Cld.Log objects from within a Cld.Context.
 */

public class Cld.LogController : Cld.AbstractController {

    /**
     * The logs that are contained in this.
     */
    private Gee.Map<string, Cld.Object> logs;


    /**
     * Default construction
     */
    public LogController () {
        _objects = new Gee.TreeMap<string, Cld.Object> ();
    }

    /**
     * Construction using an xml node
     */
    public LogController.from_xml_node (Xml.Node *node) {
        string val;

        _objects = new Gee.TreeMap<string, Cld.Object> ();

        if (node->type == Xml.ElementType.ELEMENT_NODE &&
            node->type != Xml.ElementType.COMMENT_NODE) {
            id = node->get_prop ("id");
            /* iterate through node children */
            for (Xml.Node *iter = node->children; iter != null; iter = iter->next) {
                if (iter->name == "object") {
                    switch (iter->get_prop ("type")) {
                        case "log":
                            var log = node_to_log (iter);
                            log.parent = this;
                            try {
                                add (log);
                            } catch (Cld.Error.KEY_EXISTS e) {
                                Cld.error (e.message);
                            }
                            break;
                        default:
                            break;
                    }
                }
            }
        }
    }

    private Cld.Object? node_to_log (Xml.Node *node) {
        Cld.Object object = null;

        var ltype = node->get_prop ("ltype");
        if (ltype == "csv") {
            object = new CsvLog.from_xml_node (node);
        } else if (ltype == "sqlite") {
            object = new SqliteLog.from_xml_node (node);
        }

        return object;
    }

    /**
     * {@inheritDoc}
     */
    public override void generate () {
        logs = get_object_map (typeof (Cld.Log));
//        foreach (var log in logs.values) {
//            (log as Cld.Log).connect_signals ();
//        }
    }
}
