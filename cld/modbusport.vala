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
 *  Stephen Roy <sroy1966@gmail.com>
 */

using Modbus;
/**
 * An object to use with UART and FTDI type serial ports. Pretty much pilfered
 * the code from the moserial application.
 */
public class Cld.ModbusPort : AbstractPort {

    /**
     * {@inheritDoc}
     */
    public override string id { get; set; }

    /**
     * The TCP/IP address of the ModbusPort
     */
    public string ip_address { get; set; }

    /* property backing fields */
    private bool _connected = false;

    /**
     * Used when new data arrives.
     */
    public signal void new_data (uchar[] data, int size);

    /**
     * Used when a setting has been changed.
     */
    public signal void settings_changed ();

    /**
     * Default construction.
     */
    public ModbusPort () {
        this.settings_changed.connect (update_settings);
    }

    /**
     * Full construction using available settings.
     */
    public ModbusPort.full (string id, string ip_address) {
        this.id = id;
        this.ip_address = ip_address;
        this.settings_changed.connect (update_settings);
    }

    /**
     * Alternate construction that uses an XML node to populate the settings.
     */
    public ModbusPort.from_xml_node (Xml.Node *node) {
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
                        case "ip_address":
                            device = iter->get_content ();
                            break;
                        default:
                            break;
                    }
                }
            }
        }

        this.settings_changed.connect (update_settings);
    }

    /**
     * {@inheritDoc}
     */
    public override bool open () {

        private Context ctx;
        ctx = new Context.as_tcp (ip_address, TcpAttributes.DEFAULT_PORT);
        open (ip_address);

        return true;
    }

    /**
     * {@inheritDoc}
     */
    public override void close () {
        if (connected) {
            GLib.Source.remove (source_id);
            source_id = null;
            try {
                fd_channel.shutdown (true);
            } catch (GLib.IOChannelError e) {
                warning ("%s", e.message);
            }
            non_printable = 0;
            last_rx_was_cr = false;
            fd_channel = null;
            _connected = false;
            _tx_count = 0;
            _rx_count = 0;
            tcsetattr (fd, Posix.TCSANOW, newtio);
            Posix.close (fd);
        }
    }

    /**
     *


