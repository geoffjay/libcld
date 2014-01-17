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
 *  Steve Roy <sroy1966@gmail.com>
 */

/**
 * This is very much intended to service an immediate specific need and will not
 * be suitable for a generic scenario.
 */

using Posix;

public class Cld.HeidolphModule : AbstractModule {

    /**
     * Property backing fields.
     */
    private Gee.Map<string, Cld.Object> _objects;

    public int timeout_ms { get; set; default = 400;}
    private string received = "c";
    private uint? source_id;
    private string _speed_sp;

    private string _speed;
    public string speed {
        get { return _speed; }
        }

    private string _torque;
    public string torque {
        get { return _torque; }
        }

    private string _error_status;
    public string error_status {
        get { return _error_status; }
        }

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
    public override Gee.Map<string, Cld.Object> objects {
        get { return (_objects); }
        set { update_objects (value); }
    }

    public weak Gee.Map<string, Cld.Object> channels { get; set; }


    public bool running { get; set; default = false; }

    /**
     * Default construction.
     */
    public HeidolphModule () {
    }

    /**
     * Full construction using available settings.
     */
    public HeidolphModule.full (string id, Port port) {
       this.id = id;
       this.port = port;
       this.channels = channels;
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
        Cld.debug ("Heidolph: run ()\n");
        string msg1 = "R" + _speed_sp + "\r\n";
        port.send_bytes (msg1.to_utf8 (), msg1.length);
        running = true;

        return true;
     }

    /**
     * Stop the mixer
     */
    public bool stop () {
        Cld.debug ("Heidolph: stop ()\n");
        string msg1 = "R0\r\n";
        port.send_bytes (msg1.to_utf8 (), msg1.length);
        running = false;

        return true;
    }

    /**
     * Set speed control to run from the rheostat.
     */
    public void rheostat () {
        Cld.debug ("Heidolph : rheostat ()\n");
        string msg1 = "D\r\n";
        port.send_bytes (msg1.to_utf8 (), msg1.length);
    }

    /**
     * Callback event that fetches new data from the serial port.
     */
    private bool fetch_data_cb () {
        //Cld.debug ("fetch_data_cb ()\n");
        string msg1 = "r\r\n"; // speed request message.
        string msg2 = "m\r\n"; // torque request message.
        string msg3 = "f\r\n"; // request error message.

        port.send_bytes (msg1.to_utf8 (), msg1.length);
        port.send_bytes (msg2.to_utf8 (), msg2.length);
        port.send_bytes (msg3.to_utf8 (), msg3.length);

        return true;
    }

    /**
     * Callback to parse received data.
     */
    private void new_data_cb (SerialPort port, uchar[] data, int size) {
        for (int i = 0; i < size; i++) {
            //Cld.debug ("new_data_cb ()\n");
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
                    //Cld.debug ("%s   ", r);
                    _speed = r.substring (5, -1);
                    //Cld.debug ("Speed: %s ", speed);
                } else if (r.has_prefix ("NCM")) {
                    //Cld.debug ("%s", r);
                    _torque = r.substring (5, -1);
                    //Cld.debug ("Torque: %s \n", torque);
                } else if (r.has_prefix ("FLT")) {
                    //Cld.debug ("%s\n", r);
                    _error_status = r.substring (5, -1);
                } else if (r.has_prefix ("SET")) {
                    _speed_sp = r.substring (5, -1);
                    Cld.debug ("_speed_sp: %s\n", _speed_sp);
                }
                update_raw_values ();
                received = "";
            }
        }
    }

    private void update_raw_values () {
        var channel = channels.get ("heidolph00");
        //Cld.debug ("%s: %.3f\n", channel.id, double.parse (_speed));
        (channel as VChannel).raw_value = double.parse (_speed);
        channel = channels.get ("heidolph01");
        (channel as VChannel).raw_value = double.parse (_torque);
    }

    /**
     * Set the mixer speed [RPM]
     */
    public void set_speed (string speed_set) {
        Cld.debug ("Heidolph: set_speed ()\n");
        _speed_sp = speed_set;
    }

    /**
     * XXX This doesn't work. Retrieve the speed setpoint.
     */
    public string get_speed_sp () {
        string msg1 = "s\r\n";

        port.send_bytes (msg1.to_utf8 (), msg1.length);
        Posix.sleep (5); // wait for the new data to appear

        return _speed_sp;
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
        Cld.debug ("HeidolphModule :: add_channel(%s)\n", channel.id);
    }


    /**
     * {@inheritDoc}
     */
    public override bool load () {
        loaded = true;

        if (!port.open ()) {
            Cld.debug ("Could not open port, id: %s\n", id);
            loaded = false;
        } else {
            (port as SerialPort).new_data.connect (new_data_cb);
            source_id = Timeout.add (timeout_ms, fetch_data_cb);
            Cld.debug ("HeidolphModule loaded\n");
        }
        return loaded;
    }

    /**
     * {@inheritDoc}
     */
    public override void unload () {
        if (running)
            rheostat ();
            // stop (); // Another possibility for unload.
            running = false;
        if (loaded)
            port.close ();
        Source.remove (source_id);
        source_id = null;
        loaded = false;

        Cld.debug ("HeidolphModule unloaded\n");
    }

    /**
     * {@inheritDoc}
     */
    public virtual void add (Cld.Object object) {
        Cld.debug ("HeidolphModule :: add_object(%s)", object.id);
        objects.set (object.id, object);
    }

    /**
     * {@inheritDoc}
     */
    public override void update_objects (Gee.Map<string, Cld.Object> val) {
        _objects = val;
    }
}

