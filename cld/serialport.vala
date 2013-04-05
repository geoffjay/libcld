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

using Linux;
using Posix;

/**
 * An object to use with UART and FTDI type serial ports. Pretty much pilfered
 * the code from the moserial application.
 */
public class Cld.SerialPort : AbstractPort {

    /**
     * Parity bit options.
     */
    public enum Parity {
        NONE,
        ODD,
        EVEN,
        MARK,
        SPACE;

        public string to_string () {
            switch (this) {
                case NONE:  return "None";
                case ODD:   return "Odd";
                case EVEN:  return "Even";
                case MARK:  return "Mark";
                case SPACE: return "Space";
                default: assert_not_reached ();
            }
        }

        public string to_char () {
            switch (this) {
                case NONE:  return "N";
                case ODD:   return "O";
                case EVEN:  return "E";
                case MARK:  return "M";
                case SPACE: return "S";
                default: assert_not_reached ();
            }
        }

        public Parity[] all () {
            return { NONE, ODD, EVEN, MARK, SPACE };
        }

        public Parity parse (string value) {
            try {
                var regex_none  = new Regex ("none", RegexCompileFlags.CASELESS);
                var regex_odd   = new Regex ("odd", RegexCompileFlags.CASELESS);
                var regex_even  = new Regex ("even", RegexCompileFlags.CASELESS);
                var regex_mark  = new Regex ("mark", RegexCompileFlags.CASELESS);
                var regex_space = new Regex ("space", RegexCompileFlags.CASELESS);

                if (regex_none.match (value)) {
                    return NONE;
                } else if (regex_odd.match (value)) {
                    return ODD;
                } else if (regex_even.match (value)) {
                    return EVEN;
                } else if (regex_mark.match (value)) {
                    return MARK;
                } else if (regex_space.match (value)) {
                    return SPACE;
                }
            } catch (RegexError e) {
                debug ("Error %s\n", e.message);
            }

            /* XXX need to return something */
            return NONE;
        }
    }

    /**
     * Handshake options.
     */
    public enum Handshake {
        NONE,
        HARDWARE,
        SOFTWARE,
        BOTH;

        public string to_string () {
            switch (this) {
                case NONE:     return "None";
                case HARDWARE: return "Hardware";
                case SOFTWARE: return "Software";
                case BOTH:     return "Both";
                default: assert_not_reached ();
            }
        }

        public Handshake[] all () {
            return { NONE, HARDWARE, SOFTWARE, BOTH };
        }

        public Handshake parse (string value) {
            try {
                var regex_none     = new Regex ("none", RegexCompileFlags.CASELESS);
                var regex_hardware = new Regex ("hardware", RegexCompileFlags.CASELESS);
                var regex_software = new Regex ("software", RegexCompileFlags.CASELESS);
                var regex_both     = new Regex ("both", RegexCompileFlags.CASELESS);

                if (regex_none.match (value)) {
                    return NONE;
                } else if (regex_hardware.match (value)) {
                    return HARDWARE;
                } else if (regex_software.match (value)) {
                    return SOFTWARE;
                } else if (regex_both.match (value)) {
                    return BOTH;
                }
            } catch (RegexError e) {
                debug ("Error %s\n", e.message);
            }

            /* XXX need to return something */
            return NONE;
        }
    }

    /**
     * Access options.
     */
    public enum AccessMode {
        READWRITE,
        READONLY,
        WRITEONLY;

        public string to_string () {
            switch (this) {
                case READWRITE: return "Read and Write";
                case READONLY:  return "Read Only";
                case WRITEONLY: return "Write Only";
                default: assert_not_reached ();
            }
        }

        public AccessMode[] all () {
            return { READWRITE, READONLY, WRITEONLY };
        }

        public AccessMode parse (string value) {
            try {
                var regex_rw = new Regex ("rw|read(\\040and\\040)*write", RegexCompileFlags.CASELESS);
                var regex_ro = new Regex ("ro|read(\\040)*only", RegexCompileFlags.CASELESS);
                var regex_wo = new Regex ("wo|write(\\040)*only", RegexCompileFlags.CASELESS);

                if (regex_rw.match (value)) {
                    return READWRITE;
                } else if (regex_ro.match (value)) {
                    return READONLY;
                } else if (regex_wo.match (value)) {
                    return WRITEONLY;
                }
            } catch (RegexError e) {
                debug ("Error %s\n", e.message);
            }

            /* XXX need to return something */
            return READWRITE;
        }
    }

    /**
     * {@inheritDoc}
     */
    public override string id { get; set; }

    /* property backing fields */
    private bool _connected = false;
    private ulong _tx_count = 0;
    private ulong _rx_count = 0;

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

    /* XXX sub class SerialPort.Settings ??? */

    public string device { get; set; default = "/dev/ttyS0"; }

    public Parity parity { get; set; default = Parity.NONE; }

    public Handshake handshake { get; set; default = Handshake.HARDWARE; }

    public AccessMode access_mode { get; set; default = AccessMode.READWRITE; }

    public int baud_rate { get; set; default = 1200; }

    public int data_bits { get; set; default = 8; }

    public int stop_bits { get; set; default = 1; }

    public bool echo { get; set; default = false; }

    /**
     * Private serial port specific variables.
     */
    private Posix.termios newtio;
    private Posix.termios oldtio;
    private int fd = -1;
    private GLib.IOChannel fd_channel;
    private int flags = 0;
    private int bufsz = 128;

    /**
     * Signal for new data arrival.
     */
    public signal void new_data (uchar[] data, int size);

    /**
     * Default construction.
     */
    public SerialPort () { }

    /**
     * Full construction using available settings.
     */
    public SerialPort.full (string device, int baud_rate, int data_bits,
                            int stop_bits, Parity parity, Handshake handshake,
                            AccessMode access_mode, bool echo) {
        this.device = device;
        this.baud_rate = baud_rate;
        this.data_bits = data_bits;
        this.stop_bits = stop_bits;
        this.parity = parity;
        this.handshake = handshake;
        this.access_mode = access_mode;
        this.echo = echo;
    }

    /**
     * Alternate construction that uses an XML node to populate the settings.
     */
    public SerialPort.from_xml_node (Xml.Node *node) {
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
                        case "device":
                            device = iter->get_content ();
                            break;
                        case "baudrate":
                            val = iter->get_content ();
                            baud_rate = int.parse (val);
                            break;
                        case "databits":
                            val = iter->get_content ();
                            data_bits = int.parse (val);
                            break;
                        case "stopbits":
                            val = iter->get_content ();
                            stop_bits = int.parse (val);
                            break;
                        case "parity":
                            val = iter->get_content ();
                            parity = Parity.parse (val);
                            break;
                        case "handshake":
                            val = iter->get_content ();
                            handshake = Handshake.parse (val);
                            break;
                        case "accessmode":
                            val = iter->get_content ();
                            access_mode = AccessMode.parse (val);
                            break;
                        case "echo":
                            val = iter->get_content ();
                            echo = bool.parse (val);
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
    public override bool open () {
        return false;
    }

    /**
     * {@inheritDoc}
     */
    public override void close () {
    }

    /**
     * {@inheritDoc}
     */
    public override void send_byte (uchar byte) {
    }

    /**
     * {@inheritDoc}
     */
    public override void send_bytes (char[] bytes, size_t size) {
    }

    /**
     * {@inheritDoc}
     */
    public override bool read_bytes (GLib.IOChannel source, GLib.IOCondition condition) {
        return false;
    }

    /**
     * {@inheritDoc}
     */
    public override string to_string () {
        return base.to_string ();
    }
}
