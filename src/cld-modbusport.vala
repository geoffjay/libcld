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

using Modbus;

/**
 * An object to use with UART and FTDI type serial ports. Pretty much pilfered
 * the code from the moserial application.
 */
public class Cld.ModbusPort : AbstractPort {

    private Modbus.Context ctx;

    /* property backing fields */
    private bool _connected = false;

    /**
     * {@inheritDoc}
     */
    public override bool connected {
        get { return _connected; }
    }

    /**
     * {@inheritDoc}
     */
    public override ulong tx_count {
        get { return 0; }
    }

    /**
     * {@inheritDoc}
     */
    public override ulong rx_count {
        get { return 0; }
    }

    /**
     * The TCP/IP address of the ModbusPort
     */
    public string ip_address { get; set; }

    /**
     * Used when a setting has been changed.
     */
    public signal void settings_changed ();

    /**
     * Default construction.
     */
    public ModbusPort () {
        this.settings_changed.connect (update_settings);
        debug ("also done");
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
                           ip_address = iter->get_content ();
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
     * XXX These functions are not implemented by ModbusPort.
     **/
    private void update_settings () {}

    public override void send_byte (uchar byte) {}
    public override void send_bytes (char[] bytes, size_t size) {}
    public override bool read_bytes (GLib.IOChannel source, GLib.IOCondition condition) {
        return false;
        }

    /**
     * {@inheritDoc}
     */
    public override bool open () {
        ctx = new Modbus.Context.tcp (ip_address, TcpAttributes.DEFAULT_PORT);
        if (ctx.connect () == -1) {
            message ("Connection failed.");
            _connected = false;
            return false;
        } else {
             _connected = true;
            return true;
        }
    }

    /**
     * {@inheritDoc}
     */
    public override void close () {
        if (connected) {
            ctx.close ();
            _connected = false;
            debug ("Closed Modbus port.");
            }
    }

    /**
     * Read modbus registers and store in an array.
     **/
    public void read_registers (int addr, uint16[] dest) {
        if  (ctx == null)
            message ("Port has no context");
            if (ctx.read_registers (addr, dest) == -1)
                message ("Modbus read error.");
     }

     /**
      * Write modbus register.
      **/
    public void write_register (int addr, int val) {
        if  (ctx == null)
            message ("Port has no context");
            if (ctx.write_register (addr, val) == -1)
                message ("Modbus write single register error.");
    }

    /**
     * Write to multiple registers.
     **/
    public void write_registers (int addr, uint16[] data) {
        if (ctx == null)
            message ("Port has no context.");
            if (ctx.write_registers (addr, data) == -1)
                message ("Modbus write registers error.");
    }
}
