/**
 * Copyright (C) 2010 Geoff Johnson <geoff.jay@gmail.com>
 *
 * This file is part of libcld.
 *
 * libcld is free software; you can redistribute it and/or modify
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

    /**
     * class to build objects from xml data
     */
    public class Builder : GLib.Object {

        public Cld.XmlConfig xml { get; set; }
        public Gee.Map<string, Cld.Object> objects { get; set; }

        public Builder.from_file (string filename) {
            xml = new Cld.XmlConfig (filename);
        }

        public Builder.from_xmlconfig (Cld.XmlConfig xml) {
            GLib.Object (xml: xml);
        }

        construct {
            objects = new Gee.TreeMap<string, Cld.Object> ();
        }

        /**
         * Add a object to the array list of objects
         *
         * @param object object object to add to the list
         */
        public void add (Cld.Object object) {
            objects.set (object.id, object);
        }

        /* -- methods for using the xml data -- */

        private static void load_objects () {

        }

        public void sort_objects () {
            Gee.List<Cld.Object> map_values = new Gee.ArrayList<Cld.Object> ();

            map_values.add_all (objects.values);
            map_values.sort ((GLib.CompareFunc) Cld.Object.compare);
            objects.clear ();
            foreach (Cld.Object object in map_values) {
                objects.set (object.id, object);
            }
        }

        /**
         * xml_node_to_channel
         *
         * @param:
         * @return:
         */
        public static Cld.Channel xml_node_to_channel (Xml.Node *node) {
        }

        /**
         * build_channel_map
         *
         * @param:
         * @return:
         */
        public static Gee.Map<string, Cld.Object> build_channel_map (Cld.XmlConfig cfg, string chartref) {
            /* request the nodeset from the configuration */
            string xpath = "/cld/object[@chartref=\"%s\"]/object[@class=\"CldTrace\"]".printf (chartref);
            Xml.XPath.NodeSet *nodes = cfg.nodes_from_xpath (xpath);
            Xml.Node *node = nodes->item (0);
            Gee.Map<string, Cld.Trace> traces = new Gee.TreeMap<string, Cld.Trace> ();

            for (Xml.Node *iter = node; iter != null; iter = iter->next) {
                if (iter->type == Xml.ElementType.ELEMENT_NODE) {
                    /* for some reason this isn't being restricted to the element requested
                     * by the xpath query so this additional check is required */
                    if (iter->name == "trace") {
                        Cld.Trace trace = xml_node_to_trace (iter);
                        traces.set (trace.id, trace);
                    }
                }
            }

            return traces;
        }
    }
}
