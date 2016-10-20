/**
 * libcld
 * Copyright (c) 2015, Geoff Johnson, All rights reserved.
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 3.0 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library.
 */

namespace Cld {
    /**
     * Error types for XML configurations.
     */
    public errordomain XmlError {
        FILE_NOT_FOUND,
        XML_DOCUMENT_EMPTY,
        INVALID_XPATH_EXPR
    }
}

/**
 * XML configuration used to build objects in collections using the
 * builder class.
 */
public class Cld.XmlConfig : GLib.Object {

    /**
     * The configuration file to use.
     */
    public string file_name { get; set; }

    private Xml.Doc *doc;
    private Xml.Node* root;
    private Xml.XPath.Context *ctx;
    private Xml.XPath.Object *obj;

    // Line indentation
    private int indent = 0;

    /**
     * Default construction
     */
    public XmlConfig () {
        file_name = "cld.xml";
        try {
            load_document (this.file_name);
        } catch (Cld.XmlError e) {
            error (e.message);
        }
    }

    /**
     * Constructs a new configuration using the file name provided.
     *
     * @param file_name the name of the file on disk to use
     */
    public XmlConfig.with_file_name (string file_name) {
        this.file_name = file_name;
        try {
            load_document (this.file_name);
        } catch (Cld.XmlError e) {
            error (e.message);
        }

    }

    /**
     * Constructs a new configuration using the node provided.
     *
     * @param node the node to add to the root
     */
    public XmlConfig.from_node (Xml.Node *node) {
        doc = new Xml.Doc ("1.0");
        root = new Xml.Node (null, "cld");
        doc->set_root_element (root);
        root->add_child (node);
        ctx = new Xml.XPath.Context (doc);
        ctx->register_ns ("cld", "urn:libcld");
    }

    private void load_document (string file_name) throws Cld.XmlError {
        /* load XML document */
        doc = Xml.Parser.parse_file (file_name);
        if (doc == null) {
            throw new Cld.XmlError.FILE_NOT_FOUND (
                    "file %s not found or permissions missing", file_name
                );
        }

        /* create xpath evaluation context */
        ctx = new Xml.XPath.Context (doc);
        ctx->register_ns ("cld", "urn:libcld");
    }

    /**
     * ...
     *
     * @param config ...
     */
    public void update_config (Cld.Context cld_context) {
//        var objects = cld_context.get_object_map (typeof (Cld.Object));

      // Let's parse those nodes
//        parse_node (root);

//        foreach (Cld.Object object in objects.values) {
//            message ("%s", object.uri);
//            if (object is Cld.Channel) {
//                debug ("Changing %s description to %s",
//                    object.id, (object as Cld.Channel).desc);
//
//                /* update the Channel values of the XML data in memory */
//                var xpath_base = "//cld/cld:objects/cld:object";
//
//                var xpath = "%s[@type=\"channel\" and @id=\"%s\"]/cld:property[@name=\"desc\"]".printf (xpath_base, object.id);
//                try {
//                edit_node_content (xpath, (object as Cld.Channel).desc);
//                } catch (Cld.XmlError e) {
//                    error (e.message);
//                }
//
//            } else if (object is Cld.AIChannel) {
//
//            } else if (object is Cld.AOChannel) {
//
//            } else if (object is Cld.DIChannel) {
//
//            } else if (object is Cld.VChannel) {
//
//            } else if (object is Cld.Calibration) {
//                /**/
//                 * Edit the following properties:
//                 * - Map<Coefficient>
//                 * - units
//                 */
//                debug ("Changing %s units to %s",
//                              object.id, (object as Cld.Calibration).units);
//
//                /* update the calibration settings of the xml data in memory */
//                var xpath_base = "//cld/cld:objects/cld:object";
//
//                var xpath = "%s[@type=\"calibration\" and @id=\"%s\"]/cld:property[@name=\"units\"]".printf (xpath_base, object.id);
//                try {
//                    edit_node_content (xpath, (object as Cld.Calibration).units);
//                    var coefficients = (object as Cld.Calibration).coefficients;
//                    update_coefficient_config (object.id, (object as Calibration).coefficients);
//                } catch (Cld.XmlError e) {
//                    error (e.message);
//                }
//
//            } else if (object is Cld.Control) {
//                foreach (var control in (object as Container).objects.values) {
//                    /**
//                     * Edit the following properties:
//                     * - kp
//                     * - ki
//                     * - kd
//                     * - dt
//                     * - pv_id
//                     * - mv_id
//                     */
//                    if (control is Cld.Pid) {
//                        var process_values = (control as Cld.Pid).process_values;
//                        var pv = process_values.get ("pv0");
//                        var mv = process_values.get ("pv1");
//                        debug ("Control - %s: (PV: %s) & (MV: %s)", control.id, (pv as ProcessValue).chref,
//                                                                            (mv as ProcessValue).chref);
//                        /* update the PID values of the XML data in memory */
//                        var xpath_base = "//cld/cld:objects/cld:object[@type=\"control\"]/cld:object[@id=\"%s\"]".printf (control.id);
//
//                        var xpath = "%s/cld:property[@name=\"kp\"]".printf (xpath_base);
//                        try {
//                            var value = "%.6f".printf ((control as Cld.Pid).kp);
//                            edit_node_content (xpath, value);
//                        } catch (Cld.XmlError e) {
//                            error (e.message);
//                        }
//
//                        xpath = "%s/cld:property[@name=\"ki\"]".printf (xpath_base);
//                        try {
//                            var value = "%.6f".printf ((control as Cld.Pid).ki);
//                            edit_node_content (xpath, value);
//                        } catch (Cld.XmlError e) {
//                            error (e.message);
//                        }
//
//                        xpath = "%s/cld:property[@name=\"kd\"]".printf (xpath_base);
//                        try {
//                            var value = "%.6f".printf ((control as Cld.Pid).kd);
//                            edit_node_content (xpath, value);
//                        } catch (Cld.XmlError e) {
//                            error (e.message);
//                        }
//
//                        xpath = "%s/cld:property[@name=\"dt\"]".printf (xpath_base);
//                        try {
//                            var value = "%.6f".printf ((control as Cld.Pid).dt);
//                            edit_node_content (xpath, value);
//                        } catch (Cld.XmlError e) {
//                            error (e.message);
//                        }
//
//                        /* update the channel ID references for the process values */
//                        xpath = "%s/cld:object[@id=\"%s\"]".printf (xpath_base, pv.id);
//                        try {
//                            edit_node_attribute (xpath, "chref", (pv as Cld.ProcessValue).chref);
//                        } catch (Cld.XmlError e) {
//                            error (e.message);
//                        }
//
//                        xpath = "%s/cld:object[@id=\"%s\"]".printf (xpath_base, mv.id);
//                        try {
//                            edit_node_attribute (xpath, "chref", (mv as Cld.ProcessValue).chref);
//                        } catch (Cld.XmlError e) {
//                            error (e.message);
//                        }
//
//                    } else if (control is Cld.Pid2) {
//                        var process_values = (control as Cld.Pid2).process_values;
//                        var pv = process_values.get ("pv0");
//                        var mv = process_values.get ("pv1");
//
//                        /* update the PID values of the XML data in memory */
//                        var xpath_base = "//cld/cld:objects/cld:object[@type=\"control\"]/cld:object[@id=\"%s\"]".printf (control.id);
//                        var xpath = "%s/cld:property[@name=\"kp\"]".printf (xpath_base);
//                        var value = "%.6f".printf ((control as Cld.Pid2).kp);
//                        debug ("Control - %s: (PV: %s) & (MV: %s)", control.id, (pv as ProcessValue2).dsref,
//                                                                            (mv as ProcessValue2).dsref);
//                        try {
//                            edit_node_content (xpath, value);
//                        } catch (Cld.XmlError e) {
//                            error (e.message);
//                        }
//
//                        xpath = "%s/cld:property[@name=\"ki\"]".printf (xpath_base);
//                        value = "%.6f".printf ((control as Cld.Pid2).ki);
//                        try {
//                            edit_node_content (xpath, value);
//                        } catch (Cld.XmlError e) {
//                            error (e.message);
//                        }
//
//                        xpath = "%s/cld:property[@name=\"kd\"]".printf (xpath_base);
//                        value = "%.6f".printf ((control as Cld.Pid2).kd);
//                        try {
//                            edit_node_content (xpath, value);
//                        } catch (Cld.XmlError e) {
//                            error (e.message);
//                        }
//
//                        xpath = "%s/cld:property[@name=\"dt\"]".printf (xpath_base);
//                        value = "%.6f".printf ((control as Cld.Pid2).dt);
//                        try {
//                            edit_node_content (xpath, value);
//                        } catch (Cld.XmlError e) {
//                            error (e.message);
//                        }
//
//                        /* update the channel ID references for the process values */
//                        xpath = "%s/cld:object[@id=\"%s\"]".printf (xpath_base, pv.id);
//                        try {
//                            edit_node_attribute (xpath, "dsref", (pv as Cld.ProcessValue2).dsref);
//                        } catch (Cld.XmlError e) {
//                            error (e.message);
//                        }
//
//                        xpath = "%s/cld:object[@id=\"%s\"]".printf (xpath_base, mv.id);
//                        try {
//                            edit_node_attribute (xpath, "dsref", (mv as Cld.ProcessValue2).dsref);
//                        } catch (Cld.XmlError e) {
//                            error (e.message);
//                        }
//                    }
//                }
//            } else if (object is Cld.Module) {
//                /**
//                 * Edit the following properties:
//                 * - program
//                 */
//                /* update the module content of the XML data in memory */
//                var xpath_base = "//cld/cld:objects/cld:object";
//                if (object is Cld.VelmexModule) {
//                    debug ("Changing VelmexModule %s program to %s", object.id, (object as Cld.VelmexModule).program);
//                    var xpath = "%s[@type=\"module\" and @id=\"%s\"]/cld:property[@name=\"program\"]".printf (xpath_base, object.id);
//                    try {
//                        edit_node_content (xpath, (object as Cld.VelmexModule).program);
//                    } catch (Cld.XmlError e) {
//                        error (e.message);
//                    }
//                }
//            } else if (object is Cld.Log) {
//                /**
//                 * Edit the following properties:
//                 * - name
//                 * - path
//                 * - file
//                 * - date format
//                 * - rate
//                 */
//                /* XXX add better debugging */
//                debug ("Changing log file %s", object.id);
//
//                /* update the AI channel values of the XML data in memory */
//                var xpath_base = "//cld/cld:objects/cld:object[@type=\"log\" and @id=\"%s\"]".printf (object.id);
//
//                var xpath = "%s/cld:property[@name=\"title\"]".printf (xpath_base);
//                try {
//                    edit_node_content (xpath, (object as Cld.Log).name);
//                } catch (Cld.XmlError e) {
//                    error (e.message);
//                }
//
//                xpath = "%s/cld:property[@name=\"path\"]".printf (xpath_base);
//                try {
//                    edit_node_content (xpath, (object as Cld.Log).path);
//                } catch (Cld.XmlError e) {
//                    error (e.message);
//                }
//
//                xpath = "%s/cld:property[@name=\"file\"]".printf (xpath_base);
//                try {
//                    edit_node_content (xpath, (object as Cld.Log).file);
//                } catch (Cld.XmlError e) {
//                    error (e.message);
//                }
//
//                xpath = "%s/cld:property[@name=\"format\"]".printf (xpath_base);
//                try {
//                    edit_node_content (xpath, (object as Cld.Log).date_format);
//                } catch (Cld.XmlError e) {
//                    error (e.message);
//                }
//
//                xpath = "%s/cld:property[@name=\"rate\"]".printf (xpath_base);
//                try {
//                    var value = "%.3f".printf ((object as Cld.Log).rate);
//                    edit_node_content (xpath, value);
//                } catch (Cld.XmlError e) {
//                    error (e.message);
//                }
//            }
//        }
    }

    private void update_coefficient_config (string calibration_id, Gee.Map<string, Cld.Object> coefficients) {
        /**
         * Edit the following properties:
         * - value
         */
        foreach (var coefficient in coefficients.values) {
            var value = "%.4f".printf ((coefficient as Cld.Coefficient).value);
            debug ("Changing %s value to %s", coefficient.id, value);

            /* update the AI channel values of the XML data in memory */
            var xpath_base = "//cld/cld:objects/cld:object";

            var xpath = "%s[@type=\"calibration\" and @id=\"%s\"]/cld:object[@type=\"coefficient\" and @id=\"%s\"]/cld:property[@name=\"value\"]".printf (xpath_base, calibration_id, coefficient.id);
            try {
                edit_node_content (xpath, value);
            } catch (Cld.XmlError e) {
                error (e.message);
            }
        }
    }

    /**
     * Left over function from who knows when. Not used, consider removal.
     */
    public void print_indent (string node_name,
                              string node_content,
                              char token = '+') {
        string str_indent = string.nfill (4, ' ');
        stdout.printf ("%s%c%s: %s\n",
                       str_indent, token, node_name, node_content);
    }

    private void parse_node (Xml.Node* node) {
        this.indent++;
        // Loop over the passed node's children
        for (Xml.Node* iter = node->children; iter != null; iter = iter->next) {
            // Spaces between tags are also nodes, discard them
            if (iter->type != Xml.ElementType.ELEMENT_NODE) {
                continue;
            }

            // Get the node's name
            string node_name = iter->name;
            // Get the node's content with <tags> stripped
            string node_content = iter->get_content ();
            print_indent (node_name, node_content);

            // Now parse the node's properties (attributes) ...
            parse_properties (iter);

            // Followed by its children nodes
            parse_node (iter);
        }
        this.indent--;
    }

    private void parse_properties (Xml.Node* node) {
        // Loop over the passed node's properties (attributes)
        for (Xml.Attr* prop = node->properties; prop != null; prop = prop->next) {
            string attr_name = prop->name;

            // Notice the ->children which points to a Node*
            // (Attr doesn't feature content)
            string attr_content = prop->children->content;
            print_indent (attr_name, attr_content, '|');
        }
    }

    public int child_element_count (string xpath) throws Cld.XmlError {
        obj = ctx->eval_expression (xpath);
        /* throw an error if the xpath is invalid */
        if (obj == null)
            throw new Cld.XmlError.INVALID_XPATH_EXPR (
                    "the xpath expression %s is invalid", xpath
                );

        //var nodes = new XPath.NodeSet (obj.nodesetval);

        return (obj->nodesetval)->length ();
    }

    public void edit_node (string path,
                           string child,
                           string? id,
                           string value) throws Cld.XmlError {
        string xpath;

        if (id == null)
            xpath = "%s/%s".printf (path, child);
        else
            xpath = "%s[@id=\"%s\"]/%s".printf (path, id, child);

        obj = ctx->eval_expression (xpath);
        /* throw an error if the xpath is invalid */
        if (obj == null)
            throw new Cld.XmlError.INVALID_XPATH_EXPR (
                    "the xpath expression %s is invalid", xpath
                );

        /* update the selected nodes */
        update_xpath_nodeset (obj->nodesetval, value);
    }

    public void edit_node_content (string xpath, string value) throws Cld.XmlError {
        obj = ctx->eval_expression (xpath);
        /* throw an error if the xpath is invalid */
        if (obj == null)
            throw new Cld.XmlError.INVALID_XPATH_EXPR (
                    "the xpath expression %s is invalid", xpath
                );

        /* update the selected nodes */
        update_xpath_nodeset (obj->nodesetval, value);
    }

    public void update_xpath_nodeset (Xml.XPath.NodeSet *nodes, string value) {
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

    public void edit_node_attribute (string xpath, string name, string value) throws Cld.XmlError {
        obj = ctx->eval_expression (xpath);
        /* throw an error if the xpath is invalid */
        if (obj == null)
            throw new Cld.XmlError.INVALID_XPATH_EXPR (
                    "the xpath expression %s is invalid", xpath
                );

        /* update the selected nodes */
        update_xpath_nodeset_attribute (obj->nodesetval, name, value);
    }

    public void update_xpath_nodeset_attribute (Xml.XPath.NodeSet *nodes, string name, string value) {
        int i;
        int size = nodes->length ();

        /* loop over nodes */
        for (i = size - 1; i >= 0; i--) {
            Xml.Node *node = nodes->item (0);
            node->set_prop (name, value);
            if (node->type != Xml.ElementType.NAMESPACE_DECL)
                node = null;
        }
    }

    public void save () {
        doc->save_file (file_name);
    }

    public Xml.XPath.NodeSet * nodes_from_xpath (string xpath) throws Cld.XmlError {
        obj = ctx->eval_expression (xpath);
        /* throw an error if the xpath is invalid */
        if (obj == null)
            throw new Cld.XmlError.INVALID_XPATH_EXPR (
                    "the xpath expression %s is invalid", xpath
                );

        return obj->nodesetval;
    }

    public string value_at_xpath (string xpath) throws Cld.XmlError {
//        int i, size;
        Xml.Node *node;
        Xml.XPath.NodeSet *nodes;

        obj = ctx->eval_expression (xpath);

        /* throw an error if the xpath is invalid */
        if (obj == null)
            throw new Cld.XmlError.INVALID_XPATH_EXPR (
                    "the xpath expression %s is invalid", xpath
                );

        nodes = obj->nodesetval;
        node = nodes->item (0);

//        size = nodes->length ();
//        for (i = size - 1; i >= 0; i--) {
//            if (node->type != Xml.ElementType.NAMESPACE_DECL)
//                node = null;
//        }

        return node->get_content ();
    }

    public Xml.Node * get_node (string xpath) throws Cld.XmlError {
        obj = ctx->eval_expression (xpath);
        if (obj == null)
            throw new Cld.XmlError.INVALID_XPATH_EXPR (
                    "the xpath expression %s is invalid", xpath
                );

        Xml.XPath.NodeSet *nodes = obj->nodesetval;

        return nodes->item (0);
    }
}
