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
public class Cld.LicorModule : AbstractModule {

    /**
     * {@inheritDoc}
     */
    public override string id { get; set; }

    /**
     * {@inheritDoc}
     */
    public override bool loaded { get; set; default = false; }

    /**
     * {@inheritDoc}
     */
    public override string portref { get; set; }

    /**
     * {@inheritDoc}
     */
    public override weak Port port { get; set; }

    /**
     * The list of channels to fill with received data.
     */
    public Gee.Map<string, Object> channels { get; set; }

    private string received = "";

    private bool saw_event = false;

    /**
     * Signal to indicate that an error was seen via the diagnostic signal.
     */
    public signal void diagnostic_event (int event);

    public signal void diagnostic_reset ();

    /**
     * Default construction.
     */
    public LicorModule () { }

    /**
     * Full construction using available settings.
     */
    public LicorModule.full (string id, Port port, Gee.Map<string, Object> channels) {
        this.id = id;
        this.port = port;
        this.channels = channels;
    }

    /**
     * Alternate construction that uses an XML node to populate the settings.
     */
    public LicorModule.from_xml_node (Xml.Node *node) {
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
     * Callback event that handles new data seen on the serial port.
     */
    private void new_data_cb (SerialPort port, uchar[] data, int size) {

        for (int i = 0; i < size; i++) {
            unichar c = "%c".printf (data[i]).get_char ();
            string s = "%c".printf (data[i]);

            /* Ignore LF if last char was CR (CRLF terminator) */
            if (!(port.last_rx_was_cr && (c == '\n'))) {
                received += "%s".printf (s);
            }

            port.last_rx_was_cr = (c == '\r');

            /* This should occur for each line of data */
            if (c == '\n') {
                received = received.chug ();
                received = received.chomp ();
                string[] tokens = received.split ("\t");
                var x = 0;
                /* First token is DATAM, slice to remove */
                foreach (string token in tokens[1:tokens.length]) {
                    var id = "lc%d".printf (x++);
                    /* Assign the channel the value that was received */
                    var channel = channels.get (id);
                    (channel as VChannel).raw_value = double.parse (token);
                }

                if (tokens[tokens.length - 1] != "0") {
                    diagnostic_event (int.parse (tokens[tokens.length - 1]));
                    saw_event = true;
                } else {
                    if (saw_event) {
                        diagnostic_reset ();
                        saw_event = false;
                    }
                }

                received = "";
            }
        }
    }

    /**
     * {@inheritDoc}
     */
    public override bool load () {
        (port as SerialPort).new_data.connect (new_data_cb);

        if (!port.open ())
            return false;

        loaded = true;

        return true;
    }

    /**
     * {@inheritDoc}
     */
    public override void unload () {
        //(port as SerialPort.new_data.disconnect ();
        port.close ();
    }

    /**
     * {@inheritDoc}
     */
    public override string to_string () {
        string r;
        r  = "LicorModule [%s]\n".printf (id);
        return r;
    }
}
