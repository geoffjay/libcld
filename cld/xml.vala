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

/* didn't try having class name Xml because I assumed that would conflict,
 * or at the very least confuse */
public class Cld.XmlConfig : AbstractObject {
    /* properties */
    public string file_name { get; set; }

    /* properties - Object */
    public override string id {get; set; }

    private Xml.Doc *doc;
    private Xml.XPath.Context *ctx;
    private Xml.XPath.Object *obj;

    /* constructor */
    public XmlConfig (string file_name) {
        /* instantiate object */
        GLib.Object (file_name: file_name);

        id = "xml0";

        /* load XML document */
        doc = Xml.Parser.parse_file (file_name);
        if (doc == null) {
            throw new Cld.XmlError.FILE_NOT_FOUND ("file %s not found or permissions missing", file_name);
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
            throw new Cld.XmlError.INVALID_XPATH_EXPR ("the xpath expression %s is invalid", xpath);

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
            throw new Cld.XmlError.INVALID_XPATH_EXPR ("the xpath expression %s is invalid", xpath);

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
            throw new Cld.XmlError.INVALID_XPATH_EXPR ("the xpath expression %s is invalid", xpath);

        return obj->nodesetval;
    }

    public string value_at_xpath (string xpath) {
//        int i, size;
        Xml.Node *node;
        Xml.XPath.NodeSet *nodes;

        obj = ctx->eval_expression (xpath);

        /* throw an error if the xpath is invalid */
        if (obj == null)
            throw new Cld.XmlError.INVALID_XPATH_EXPR ("the xpath expression %s is invalid", xpath);

        nodes = obj->nodesetval;
        node = nodes->item (0);

//        size = nodes->length ();
//        for (i = size - 1; i >= 0; i--) {
//            if (node->type != Xml.ElementType.NAMESPACE_DECL)
//                node = null;
//        }

        return node->get_content ();
    }

    public override string to_string () {
        string str_data = "[%s] : XML Configuration (%s)\n".printf (
                            id, file_name);
        return str_data;
    }
}
