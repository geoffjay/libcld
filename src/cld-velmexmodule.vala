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

/**
 * This is very much intended to service an immediate specific need and will not
 * be suitable for a generic scenario.
 */
public class Cld.VelmexModule : AbstractModule {

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

        this.node = node;

        if (node->type == Xml.ElementType.ELEMENT_NODE &&
            node->type != Xml.ElementType.COMMENT_NODE) {
            id = node->get_prop ("id");
            /* iterate through node children */
            for (Xml.Node *iter = node->children;
                 iter != null;
                 iter = iter->next) {
                if (iter->name == "property") {
                    switch (iter->get_prop ("name")) {
                        case "port":
                            portref = iter->get_content ();
                            break;
                        case "program":
                            program = iter->get_content ();
                            break;
                        default:
                            break;
                    }
                }
            }
        }

        connect_signals ();
    }

    /**
     * Connect the notify signals that require the node to update.
     */
    private void connect_signals () {
        notify["program"].connect ((s, p) => {
            //debug ("Property %s changed for %s", p.get_name (), uri);
            update_node ();
        });
    }

    /**
     * Update the XML node for this object.
     */
    private void update_node () {
        for (Xml.Node *iter = node->children; iter != null; iter = iter->next) {
            if (iter->name == "property") {
                switch (iter->get_prop ("name")) {
                    case "program":
                        iter->set_content (program);
                        break;
                    default:
                        break;
                }
            }
        }
    }

    /**
     * Execute the program that is stored in the corresponding variable.
     * XXX verbose method would check port tx bytes and return false on fail.
     */
    public void store_program () {
        //string msg = "F PM0,%s".printf (program);
        string msg = "PM0,%s\r".printf (program);
        port.send_bytes (msg.to_utf8 (), msg.length);
        //Posix.usleep (50000);
        //port.send_bytes (program.to_utf8 (), program.length);
    }

    /**
     * Jog forward one step.
     */
    public void jog (int val) {
        string cmd;
        //if (val < 0)
        //    cmd = "F PM1,C,SA1M4000,A1M50,I1M%c%d\r".printf ('-', val);
        //else
            //cmd = "F PM1,C,SA1M4000,A1M50,I1M%d\r".printf (val);
            cmd = "PM1,C,SA1M4000,A1M50,I1M%d\r".printf (val);
        port.send_bytes (cmd.to_utf8 (), cmd.length);
        Posix.usleep (50000);
        port.send_byte ('R');
        //Posix.usleep (50000);
        //port.send_byte ('Q');
    }

    /**
     * Run whatever program the device currently has stored.
     */
    public void run_stored_program () {
        //string msg = "F PM0,";
        string msg = "PM0,R\r";
        port.send_bytes (msg.to_utf8 (), msg.length);
        //Posix.usleep (50000);
        //port.send_byte ('R');
        ///Posix.usleep (500000);
        ///port.send_byte ('Q');
    }

    /**
     * {@inheritDoc}
     */
    public override bool load () {
        loaded = (port.open ()) ? true : false;
        port.send_byte ('F');

        debug ("VelmexModule :: load ()");

        return loaded;
    }

    /**
     * {@inheritDoc}
     */
    public override void unload () {
        port.send_byte ('Q');
        port.close ();

        loaded = false; // XXX There is currently no way to verify this.

        debug ("VelmexModule :: unload ()");
    }
}
