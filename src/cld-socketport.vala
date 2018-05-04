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
 * An object to use as a socket client. Initially this will be very straight
 * forward and meant to serve an immediate need.
 */
public class Cld.SocketPort : AbstractPort {

    /* property backing fields */
    private bool _connected = false;
    private ulong _tx_count = 0;
    private ulong _rx_count = 0;
    private string _host = "127.0.0.1";
    private int _port = 4444;

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
        get { return _tx_count; }
    }

    /**
     * {@inheritDoc}
     */
    public override ulong rx_count {
        get { return _rx_count; }
    }

    /**
     * A host that is running a TCP service to connect to.
     */
    public string host {
        get { return _host; }
        set {
            _host = value;
            settings_changed ();
        }
    }

    /**
     * The port of the TCP service to connect to.
     */
    public int port {
        get { return _port; }
        set {
            _port = value;
            settings_changed ();
        }
    }

    /**
     * Private socket specific data.
     */
    private Resolver resolver;
    private List<InetAddress> addresses;    /* probably don't need the list  */
    private InetAddress address;
    private SocketClient client;
    private SocketConnection connection;
    private Socket socket;
    private int fd = -1;
    private GLib.IOChannel fd_channel;
    private const int bufsz = 1024;
    private uint? source_id;

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
    public SocketPort () {
        this.settings_changed.connect (update_settings);
    }

    /**
     * Full construction using available settings.
     */
    public SocketPort.full (string id, string host, int port) {
        this.id = id;
        this.host = host;
        this.port = port;

        this.settings_changed.connect (update_settings);
    }

    /**
     * Alternate construction that uses an XML node to populate the settings.
     */
    public SocketPort.from_xml_node (Xml.Node *node) {
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
                        case "host":
                            host = iter->get_content ();
                            break;
                        case "port":
                            val = iter->get_content ();
                            port = int.parse (val);
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
        try {
            resolver = Resolver.get_default ();
            addresses = resolver.lookup_by_name (host, null);
            address = addresses.nth_data (0);
            client = new SocketClient ();
            connection = client.connect (new InetSocketAddress (address, (uint16)port));
            if (connection is GLib.TcpConnection) {
                (connection as GLib.TcpConnection).set_graceful_disconnect (true);
            }

            _connected = true;

            socket = connection.socket;
            fd = socket.fd;
            fd_channel = new GLib.IOChannel.unix_new (fd);
            source_id = fd_channel.add_watch (GLib.IOCondition.IN, this.read_bytes);
        } catch (GLib.Error e) {
            critical ("Socket connection error: %s", e.message);
            return false;
        }

        return true;
    }

    /**
     * {@inheritDoc}
     */
    public override void close () {
        if (connected) {
            try {
                connection.close ();
            } catch (GLib.Error e) {
                warning ("%s", e.message);
            }
        }
    }

    /**
     * {@inheritDoc}
     */
    public override void send_byte (uchar byte) {

        if (connected) {
            uchar[] b = new uchar[1];
            b[0] = byte;
            size_t n;
            string command = "";

            foreach (var c in b) {
                command += "%c".printf (c);
            }

            try {
                connection.output_stream.write_all (command.data, out n);
                _tx_count += n;
            } catch (GLib.IOError e) {
                critical (e.message);
            }
        }
    }

    /**
     * {@inheritDoc}
     */
    public override void send_bytes (char[] bytes, size_t size) {

        if (connected) {
            size_t n;
            string command = "";

            foreach (var byte in bytes) {
                command += "%c".printf (byte);
            }

            try {
                connection.output_stream.write_all (command.data, out n);
                _tx_count += n;
            } catch (GLib.IOError e) {
                critical (e.message);
            }
        }
    }

    /**
     * {@inheritDoc}
     */
    public override bool read_bytes (GLib.IOChannel source, GLib.IOCondition condition) {

        uchar[] buf = new uchar[bufsz];
        int nread = (int)Posix.read (fd, buf, bufsz);
        _rx_count += (ulong)nread;

        if (nread < 0)
            return false;

        uchar[] sized_buf = new uchar[nread];

        for (int i = 0; i < nread; i++) {
            sized_buf[i] = buf[i];
        }

        new_data (sized_buf, nread);

        return connected;
    }

//    /**
//     * {@inheritDoc}
//     */
//    public override string to_string () {
//        string r;
//        r  = "SocketPort [%s]\n".printf (id);
//        r += " connected:   %s\n".printf ((connected) ? "Yes" : "No");
//        r += " host:        %s\n".printf (host);
//        r += " port:        %d\n".printf (port);
//        r += " tx count:    %lu\n".printf (tx_count);
//        r += " rx count:    %lu\n".printf (rx_count);
//        return r;
//    }

    /**
     * Update the socket settings.
     */
    private void update_settings () {
        /* XXX maybe not necessary??? */
    }
}
