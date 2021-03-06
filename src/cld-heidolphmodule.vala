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

using Posix;

public class Cld.HeidolphModule : Cld.AbstractModule {

    /**
     * Property backing fields.
     */
    private string _speed_sp;
    private string _speed = "0";
    private string _torque = "0";
    private string _error_status;

    /**
     * Properties
     */
    public int timeout_ms { get; set; default = 400;}

    public string speed_sp {
        get { return _speed_sp; }
        set { _speed_sp = value; }
    }

    public string speed {
        get { return _speed; }
    }

    public string torque {
        get { return _torque; }
    }

    public string error_status {
        get { return _error_status; }
    }

    public Gee.Map<string, Cld.Object> channels { get; set; }

    public bool running { get; set; default = false; }

    private string old_speed_sp = "0";
    private string received = "c";
    private uint? source_id;

    /**
     * Default construction.
     */
    public HeidolphModule () { }

    /**
     * Full construction using available settings.
     */
    public HeidolphModule.full (string id, Port port) {
        this.id = id;
        this.port = port;
        channels = new Gee.TreeMap<string, Cld.Object> ();
    }

    /**
     * Alternate construction method that uses an XML node to populate the settings.
     */
    public HeidolphModule.from_xml_node (Xml.Node *node) {
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
                        case "devref":
                            devref = iter->get_content ();
                            break;
                        default:
                            break;
                    }
                }
            }
        }
        channels = new Gee.TreeMap<string, Cld.Object> ();
    }

    /**
     * Start the mixer
     */
     public bool run () {
        string msg1 = "R" + _speed_sp + "\r\n";

        debug ("Heidolph: run ()");
        source_id = Timeout.add (timeout_ms, fetch_data_cb);
        port.send_bytes (msg1.to_utf8 (), msg1.length);
        running = true;

        return true;
     }

    /**
     * Stop the mixer
     */
    public bool stop () {
        string msg1 = "R0\r\n";

        debug ("Heidolph: stop ()");
        port.send_bytes (msg1.to_utf8 (), msg1.length);
        running = false;

        return true;
    }

    /**
     * Set speed control to run from the rheostat.
     */
    public void rheostat () {
        string msg1 = "D\r\n";

        debug ("Heidolph : rheostat ()");
        port.send_bytes (msg1.to_utf8 (), msg1.length);
    }

    /**
     * Callback event that fetches new data from the serial port.
     */
    private bool fetch_data_cb () {
        if (running) {
            string msg1 = "r"; // speed request message.
            string msg2 = "m"; // torque request message.
            string msg3 = "f"; // request error message.
            string msg4 = "R" + _speed_sp + "\r\n";

            port.send_bytes (msg1.to_utf8 (), msg1.length);
            port.send_bytes (msg2.to_utf8 (), msg2.length);
            port.send_bytes (msg3.to_utf8 (), msg3.length);

            if (_speed_sp != old_speed_sp) {
                port.send_bytes (msg4.to_utf8 (), msg4.length);
                old_speed_sp = _speed_sp;
            }

            return true;
        } else {
            return false;
        }
    }

    /**
     * Callback to parse received data.
     */
    private void new_data_cb (SerialPort port, uchar[] data, int size) {
        for (int i = 0; i < size; i++) {
            //debug ("new_data_cb () size: %d", size);
            unichar c = "%c".printf (data[i]).get_char ();
            string s = "%c".printf (data[i]);

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
                    _speed = r.substring (5, -1);
                    var channel = channels.get ("heidolph00");
                    (channel as VChannel).raw_value = double.parse (_speed);
                    debug ("Speed: %s", speed);
                } else if (r.has_prefix ("NCM")) {
                    _torque = r.substring (5, -1);
                    var channel = channels.get ("heidolph01");
                    (channel as VChannel).raw_value = double.parse (_torque);
                    //debug ("Torque: %s", torque);
                } else if (r.has_prefix ("FLT")) {
                    _error_status = r.substring (5, -1);
                    //debug ("Err: %s", error_status);
                } else if (r.has_prefix ("SET")) {
                    _speed_sp = r.substring (5, -1);
                    debug ("_speed_sp: %s", _speed_sp);
                }
                received = "";
            }
        }
    }

    /**
     * Normalize the torque value.
     */
    public void normalize () {
        string msg1 = "N\r\n";
        port.send_bytes (msg1.to_utf8 (), msg1.length);
    }

    /**
     * ...
     */
    public void add_channel (Cld.Object channel) {
        channels.set (channel.id, channel);
        debug ("HeidolphModule :: add_channel(%s)", channel.id);
    }

    public void set_speed (string speed_set) {
        debug ("Heidolph: set_speed ()\n");
        _speed_sp = speed_set;
    }

    /**
     * {@inheritDoc}
     */
    public override bool load () {
        loaded = true;

        if (!port.open ()) {
            warning ("Could not open port, id: %s", id);
            loaded = false;
        } else {
            (port as SerialPort).new_data.connect (new_data_cb);
            debug ("HeidolphModule loaded");
        }
        return loaded;
    }

    /**
     * {@inheritDoc}
     */
    public override void unload () {
        /* XXX probably a logic error, needs review */
        if (running)
            rheostat ();
            //stop (); // Another possibility for unload.
            running = false;
        if (loaded)
            (port as SerialPort).new_data.disconnect (new_data_cb);
            port.close ();
        received = "";
        source_id = null;
        loaded = false;

        debug ("HeidolphModule unloaded");
    }
}
