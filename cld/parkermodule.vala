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
 *  Steve Roy <sroy1966@gmail.com>
 */
using Posix;

/**
 * This is very much intended to service an immediate specific need and will not
 * be suitable for a generic scenario.
 */
public class Cld.ParkerModule : AbstractModule {

    /**
     * Property backing fields.
     */
    private Gee.Map<string, Object> _objects;

    private string received = "";

    /**
     * {@inheritDoc}
     */
    public override string id { get; set; }

    /**
     * {@inheritDoc}
     */
    public override bool loaded { get; set; default = false; }

    /**
     * {@inheritdoc}
     */
    public override string devref { get; set; }

    /**
     * {@inheritDoc}
     */
    public override string portref { get; set; }

    /**
     * {@inheritDoc}
     */
    public override weak Port port { get; set; }

    /**
     * {@inheritDoc}
     */
    public override Gee.Map<string, Object> objects {
        get { return (_objects); }
        set { update_objects (value); }
    }

    /**
     * Full construction using available settings.
     */
    public ParkerModule.full (string id, Port port) {
        this.id = id;
        this.port = port;
    }

    /**
     * Alternate construction that uses an XML node to populate the settings.
     */
    public ParkerModule.from_xml_node (Xml.Node *node) {
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
                        case "port":
                            portref = iter->get_content ();
                            break;
                        default:
                            break;
                    }
                }
            }
        }
    }

    /**
     * {@inheritDoc}
     */
    public override bool load () {
        loaded = true;

        if (!port.open ()) {
            Cld.debug ("Could not open port, id: %s\n", port.id);
            loaded = false;
        } else {
            (port as SerialPort).new_data.connect (new_data_cb);
            Cld.debug ("ParkerModule loaded\n");
        }
        loaded = (port.open ()) ? true : false;

        return loaded;
    }

    /**
     * {@inheritDoc}
     */
    public override void unload () {
        Cld.debug ("ParkerModule :: unload ()\n");
        port.close ();
        loaded = false;
    }

    /**
     * {@inheritDoc}
     */
    public override void update_objects (Gee.Map<string, Object> val) {
        _objects = val;
    }

    /**
     * {@inheritDoc}
     */
    public override string to_string () {
        string r;
        r  = "ParkerModule [%s]\n".printf (id);
        return r;
    }


    public void jog (double val) {
        Cld.debug ("jog: %.3f\n", val);
        string msg1 = "jog: Hello World!\r\n";
        port.send_bytes (msg1.to_utf8 (), msg1.length);
        Posix.usleep (100000);
   }

    private void new_data_cb (SerialPort port, uchar[] data, int size) {
        //Cld.debug ("new_data_cb ()\n");
        for (int i = 0; i < size; i++) {
            unichar c = "%c".printf (data[i]).get_char ();
            string s = "%c".printf (data[i]);
            //Cld.debug ("%s   %d\n", s, size);

            /* Ignore LF if last char was CR (CRLF terminator) */
            if (!(port.last_rx_was_cr && (c == '\n'))) {
                received += "%s".printf (s);
            }

            port.last_rx_was_cr = (c == '\r');

            if (c == '\n') {
                string r = "";
                received = received.chug ();
                received = received.chomp ();
                string[] tokens = received.split ("\t");
                foreach (string token in tokens[0:tokens.length]) {
                    r += "%s\t".printf (token);
                }
                r = r.substring (0, r.length - 1);
                if (r.has_prefix ("RPM")) {
                    Cld.debug ("%s   \n", r.substring (5, -1));
                } else if (r.has_prefix ("FLT")) {
                } else if (r.has_prefix ("SET")) {
                }
                received = "";
            }
        }
    }

    public void home () {
        Cld.debug ("home ()\n");
        string msg1 = "O $4003\r";
        port.send_bytes (msg1.to_utf8 (), msg1.length);
        Posix.usleep (100000);
    }

    public void withdraw (double length_mm, double speed_mmps) {
        Cld.debug ("withdraw (): length: %.3f speed: %.3f\n", length_mm, speed_mmps);
    }

    public void inject (double speed_mmps) {
        Cld.debug ("inject (): speed: %.3f\n", speed_mmps);
    }

    public double get_position () {

        return 123.456;
    }
}
