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
 * This is very much intended to service an immediate specific need and will not
 * be suitable for a generic scenario.
 *
 * XXX should be a container.
 * XXX should be buildable using XML.
 */
public class Cld.VelmexModule : AbstractModule {

    /**
     * {@inheritDoc}
     */
    public override string id { get; set; }

    public override bool loaded { get; set; default = false; }

    /**
     * The port to connect to the Licor with.
     */
    public Port port { get; set; }

    /**
     * The program commands to be executed on apply_program.
     */
    public string program { get; set; }

    /**
     * Default construction.
     */
    public VelmexModule () { }

    /**
     * Full construction using available settings.
     */
    public VelmexModule.full (string id, Port port) {
        this.id = id;
        this.port = port;
    }

    /**
     * Alternate construction that uses an XML node to populate the settings.
     */
    public VelmexModule.from_xml_node (Xml.Node *node) {
        string val;

        if (node->type == Xml.ElementType.ELEMENT_NODE &&
            node->type != Xml.ElementType.COMMENT_NODE) {
            id = node->get_prop ("id");
            /* iterate through node children */
            for (Xml.Node *iter = node->children;
                 iter != null;
                 iter = iter->next) {
                if (iter->name == "property") {
                    switch (iter->get_prop ("name")) {
                        /*
                         *case "":
                         *     = iter->get_content ();
                         *    break;
                         */
                        default:
                            break;
                    }
                }
            }
        }
    }

    /**
     * Execute the program that is stored in the corresponding variable.
     * XXX verbose method would check port tx bytes and return false on fail.
     */
    public void store_program () {
        port.send_bytes (program.to_utf8 (), program.length);
    }

    /**
     * Run whatever program the device currently has stored.
     */
    public void run_stored_program () {
        port.send_byte ('R');
    }

    /**
     * {@inheritDoc}
     */
    public override bool load () {
        if (!port.open ())
            return false;

        loaded = true;

        return true;
    }

    /**
     * {@inheritDoc}
     */
    public override void unload () {
        port.close ();
    }

    /**
     * {@inheritDoc}
     */
    public override string to_string () {
        string r;
        r  = "VelmexModule [%s]\n".printf (id);
        return r;
    }
}
