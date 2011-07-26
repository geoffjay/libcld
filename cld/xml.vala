/*
** Copyright (C) 2010 Geoff Johnson <geoff.jay@gmail.com>
**
** This program is free software; you can redistribute it and/or modify
** it under the terms of the GNU General Public License as published by
** the Free Software Foundation; either version 2 of the License, or
** (at your option) any later version.
**
** This program is distributed in the hope that it will be useful,
** but WITHOUT ANY WARRANTY; without even the implied warranty of
** MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
** GNU General Public License for more details.
**
** You should have received a copy of the GNU General Public License
** along with this program; if not, write to the Free Software
** Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
*/

using GLib;
using Xml;

namespace Cld {

    public errordomain XmlError {
        FILE_NOT_FOUND,
        XML_DOCUMENT_EMPTY,
        INVALID_XPATH_EXPR
    }

    /* didn't try having class name Xml because I assumed that would conflict,
     * or at the very least confuse */
    public class XmlConfig : Object {
        /* properties */
        [Property(nick = "", blurb = "")]
        public string file_name { get; set; }

        private Xml.Doc *doc;
        private Xml.XPath.Context *ctx;
        private Xml.XPath.Object *obj;

        /* constructor */
        public XmlConfig (string file_name) {
            /* instantiate object */
            Object (file_name: file_name);

            /* load XML document */
            doc = Xml.Parser.parse_file (file_name);
            if (doc == null) {
                throw new XmlError.FILE_NOT_FOUND ("file %s not found or permissions missing", file_name);
            }

            /* create xpath evaluation context */
            ctx = new Xml.XPath.Context (doc);
        }

        public void print_indent (string node_name,
                                  string node_content,
                                  char token = '+') {
            string str_indent = string.nfill (4, ' ');
            stdout.printf ("%s%c%s: %s\n", str_indent, token, node_name, node_content);
        }

        public int child_element_count (string xpath) {
            obj = ctx->eval_expression (xpath);
            /* throw an error if the xpath is invalid */
            if (obj == null)
                throw new XmlError.INVALID_XPATH_EXPR ("the xpath expression %s is invalid", xpath);

            //var nodes = new XPath.NodeSet (obj.nodesetval);

            return (obj->nodesetval)->length ();
        }

        public void edit_node (string path,
                               string child,
                               string? id,
                               string value) {
            string xpath;

            if (id == null)
                xpath = "%s/%s".printf (path, child);
            else
                xpath = "%s[@id=\"%s\"]/%s".printf (path, id, child);

            obj = ctx->eval_expression (xpath);
            /* throw an error if the xpath is invalid */
            if (obj == null)
                throw new XmlError.INVALID_XPATH_EXPR ("the xpath expression %s is invalid", xpath);

            /* update the selected nodes */
            update_xpath_nodes (obj->nodesetval, value);
        }

        public void update_xpath_nodes (Xml.XPath.NodeSet *nodes, string value) {
            int i;
            int size = nodes->length ();

            /* loop over nodes */
            for (i = size - 1; i >= 0; i--) {
                Xml.Node *node = nodes->item (0);
                node->set_content (value);
                if (node->type != Xml.ElementType.NAMESPACE_DECL)
                    node = null;
            }
        }

        public void save () {
            doc->save_file (file_name);
        }

        public Xml.XPath.NodeSet * nodes_from_xpath (string xpath) {
            obj = ctx->eval_expression (xpath);
            /* throw an error if the xpath is invalid */
            if (obj == null)
                throw new XmlError.INVALID_XPATH_EXPR ("the xpath expression %s is invalid", xpath);

            return obj->nodesetval;
        }

        public string value_at_xpath (string xpath) {
//            int i, size;
            Xml.Node *node;
            Xml.XPath.NodeSet *nodes;

            xpath_object = xpath_context.eval_expression (xpath);

            /* throw an error if the xpath is invalid */
            if (xpath_object == null)
                throw new XmlError.INVALID_XPATH_EXPR ("the xpath expression %s is invalid", xpath);

            nodes = xpath_object.nodesetval;
            node = nodes->item (0);

//            size = nodes->length ();
//            for (i = size - 1; i >= 0; i--) {
//                if (node->type != Xml.ElementType.NAMESPACE_DECL)
//                    node = null;
//            }

            return node->get_content ();
        }
    }
}
