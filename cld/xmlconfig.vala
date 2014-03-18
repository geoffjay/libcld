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
    private Xml.XPath.Context *ctx;
    private Xml.XPath.Object *obj;

    /**
     * Default construction
     */
    public XmlConfig () {
        file_name = "cld.xml";
        load_document (this.file_name);
    }

    /**
     * Constructs a new configuration using the file name provided.
     *
     * @param file_name the name of the file on disk to use
     */
    public XmlConfig.with_file_name (string file_name) {
        this.file_name = file_name;
        load_document (this.file_name);
    }

    /**
     * Constructs a new configuration using the node provided.
     *
     * @param node the node to add to the root
     */
    public XmlConfig.from_node (Xml.Node *node) {
        doc = new Xml.Doc ("1.0");
        Xml.Node *root = new Xml.Node (null, "cld");
        doc->set_root_element (root);
        root->add_child (node);
        ctx = new Xml.XPath.Context (doc);
        ctx->register_ns ("cld", "urn:libcld");
    }

    void load_document (string file_name) {
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
    public void update_config (Gee.Map<string, Cld.Object> objects) {
        foreach (Cld.Object object in objects.values) {
            if (object is Cld.Channel) {
                Cld.message ("Changing %s description to %s",
                    object.id, (object as Cld.Channel).desc);

                /* update the Channel values of the XML data in memory */
                var xpath_base = "//cld/cld:objects/cld:object";
                var xpath = "%s[@type=\"channel\" and @id=\"%s\"]/cld:property[@name=\"desc\"]".printf (xpath_base, object.id);
                edit_node_content (xpath, (object as Cld.Channel).desc);

            } else if (object is Cld.AIChannel) {

            } else if (object is Cld.AOChannel) {

            } else if (object is Cld.DIChannel) {

            } else if (object is Cld.VChannel) {

            } else if (object is Cld.Calibration) {
                /**
                 * Edit the following properties:
                 * - Map<Coefficient>
                 * - units
                 */
                Cld.message ("Changing %s units to %s",
                              object.id, (object as Cld.Calibration).units);

                /* update the calibration settings of the xml data in memory */
                var xpath_base = "//cld/cld:objects/cld:object";
                var xpath = "%s[@type=\"calibration\" and @id=\"%s\"]/cld:property[@name=\"units\"]".printf (xpath_base, object.id);
                edit_node_content (xpath, (object as Cld.Calibration).units);
                var coefficients = (object as Cld.Calibration).coefficients;
                update_coefficient_config (object.id, (object as Calibration).coefficients);

            } else if (object is Cld.Control) {
                foreach (var control in (object as Container).objects.values) {
                    /**
                     * Edit the following properties:
                     * - kp
                     * - ki
                     * - kd
                     * - dt
                     * - pv_id
                     * - mv_id
                     */
                    if (control is Cld.Pid) {
                        var process_values = (control as Cld.Pid).process_values;
                        var pv = process_values.get ("pv0");
                        var mv = process_values.get ("pv1");
                        Cld.message ("Control - %s: (PV: %s) & (MV: %s)", control.id, (pv as ProcessValue).chref,
                                                                            (mv as ProcessValue).chref);
                        /* update the PID values of the XML data in memory */
                        var xpath_base = "//cld/cld:objects/cld:object[@type=\"control\"]/cld:object[@id=\"%s\"]".printf (control.id);
                        var xpath = "%s/cld:property[@name=\"kp\"]".printf (xpath_base);
                        var value = "%.6f".printf ((control as Cld.Pid).kp);
                        edit_node_content (xpath, value);
                        xpath = "%s/cld:property[@name=\"ki\"]".printf (xpath_base);
                        value = "%.6f".printf ((control as Cld.Pid).ki);
                        edit_node_content (xpath, value);
                        xpath = "%s/cld:property[@name=\"kd\"]".printf (xpath_base);
                        value = "%.6f".printf ((control as Cld.Pid).kd);
                        edit_node_content (xpath, value);
                        xpath = "%s/cld:property[@name=\"dt\"]".printf (xpath_base);
                        value = "%.6f".printf ((control as Cld.Pid).dt);
                        edit_node_content (xpath, value);
                        /* update the channel ID references for the process values */
                        xpath = "%s/cld:object[@id=\"%s\"]".printf (xpath_base, pv.id);
                        edit_node_attribute (xpath, "chref", (pv as Cld.ProcessValue).chref);
                        xpath = "%s/cld:object[@id=\"%s\"]".printf (xpath_base, mv.id);
                        edit_node_attribute (xpath, "chref", (mv as Cld.ProcessValue).chref);
                    } else if (control is Cld.Pid2) {
                        var process_values = (control as Cld.Pid2).process_values;
                        var pv = process_values.get ("pv0");
                        var mv = process_values.get ("pv1");

                        /* update the PID values of the XML data in memory */
                        var xpath_base = "//cld/cld:objects/cld:object[@type=\"control\"]/cld:object[@id=\"%s\"]".printf (control.id);
                        var xpath = "%s/cld:property[@name=\"kp\"]".printf (xpath_base);
                        var value = "%.6f".printf ((control as Cld.Pid2).kp);
                        Cld.message ("Control - %s: (PV: %s) & (MV: %s)", control.id, (pv as ProcessValue2).dsref,
                                                                            (mv as ProcessValue2).dsref);
                        edit_node_content (xpath, value);
                        xpath = "%s/cld:property[@name=\"ki\"]".printf (xpath_base);
                        value = "%.6f".printf ((control as Cld.Pid2).ki);
                        edit_node_content (xpath, value);
                        xpath = "%s/cld:property[@name=\"kd\"]".printf (xpath_base);
                        value = "%.6f".printf ((control as Cld.Pid2).kd);
                        edit_node_content (xpath, value);
                        xpath = "%s/cld:property[@name=\"dt\"]".printf (xpath_base);
                        value = "%.6f".printf ((control as Cld.Pid2).dt);
                        edit_node_content (xpath, value);
                        /* update the channel ID references for the process values */
                        xpath = "%s/cld:object[@id=\"%s\"]".printf (xpath_base, pv.id);
                        edit_node_attribute (xpath, "dsref", (pv as Cld.ProcessValue2).dsref);
                        xpath = "%s/cld:object[@id=\"%s\"]".printf (xpath_base, mv.id);
                        edit_node_attribute (xpath, "dsref", (mv as Cld.ProcessValue2).dsref);
                    }
                }
            } else if (object is Cld.Module) {
                /**
                 * Edit the following properties:
                 * - program
                 */
                /* update the module content of the XML data in memory */
                var xpath_base = "//cld/cld:objects/cld:object";
                if (object is Cld.VelmexModule) {
                    Cld.message ("Changing VelmexModule %s program to %s", object.id, (object as Cld.VelmexModule).program);
                    var xpath = "%s[@type=\"module\" and @id=\"%s\"]/cld:property[@name=\"program\"]".printf (xpath_base, object.id);
                    edit_node_content (xpath, (object as Cld.VelmexModule).program);
                }
            } else if (object is Cld.Log) {
                /**
                 * Edit the following properties:
                 * - name
                 * - path
                 * - file
                 * - date format
                 * - rate
                 */
                /* XXX add better debugging */
                Cld.message ("Changing log file %s", object.id);

                /* update the AI channel values of the XML data in memory */
                var xpath_base = "//cld/cld:objects/cld:object[@type=\"log\" and @id=\"%s\"]".printf (object.id);
                var xpath = "%s/cld:property[@name=\"title\"]".printf (xpath_base);
                edit_node_content (xpath, (object as Cld.Log).name);
                xpath = "%s/cld:property[@name=\"path\"]".printf (xpath_base);
                edit_node_content (xpath, (object as Cld.Log).path);
                xpath = "%s/cld:property[@name=\"file\"]".printf (xpath_base);
                edit_node_content (xpath, (object as Cld.Log).file);
                xpath = "%s/cld:property[@name=\"format\"]".printf (xpath_base);
                edit_node_content (xpath, (object as Cld.Log).date_format);
                xpath = "%s/cld:property[@name=\"rate\"]".printf (xpath_base);
                var value = "%.3f".printf ((object as Cld.Log).rate);
                edit_node_content (xpath, value);
            }
        }
    }

    private void update_coefficient_config (string calibration_id, Gee.Map<string, Cld.Object> coefficients) {
        /**
         * Edit the following properties:
         * - value
         */
        foreach (var coefficient in coefficients.values) {
            var value = "%.4f".printf ((coefficient as Cld.Coefficient).value);
            Cld.message ("Changing %s value to %s", coefficient.id, value);

            /* update the AI channel values of the XML data in memory */
            var xpath_base = "//cld/cld:objects/cld:object";
            var xpath = "%s[@type=\"calibration\" and @id=\"%s\"]/cld:object[@type=\"coefficient\" and @id=\"%s\"]/cld:property[@name=\"value\"]".printf (xpath_base, calibration_id, coefficient.id);
            edit_node_content (xpath, value);
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

    public int child_element_count (string xpath) {
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
                           string value) {
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

    public void edit_node_content (string xpath, string value) {
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

    public void edit_node_attribute (string xpath, string name, string value) {
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

    public Xml.XPath.NodeSet * nodes_from_xpath (string xpath) {
        obj = ctx->eval_expression (xpath);
        /* throw an error if the xpath is invalid */
        if (obj == null)
            throw new Cld.XmlError.INVALID_XPATH_EXPR (
                    "the xpath expression %s is invalid", xpath
                );

        return obj->nodesetval;
    }

    public string value_at_xpath (string xpath) {
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

    public Xml.Node * get_node (string xpath) {
        obj = ctx->eval_expression (xpath);
        if (obj == null)
            throw new Cld.XmlError.INVALID_XPATH_EXPR (
                    "the xpath expression %s is invalid", xpath
                );

        Xml.XPath.NodeSet *nodes = obj->nodesetval;

        return nodes->item (0);
    }
}
