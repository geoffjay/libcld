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

        public static Parity[] all () {
            return { NONE, ODD, EVEN, MARK, SPACE };
        }

        public static Parity parse (string value) {
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
                message ("Error %s", e.message);
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

        public static Handshake[] all () {
            return { NONE, HARDWARE, SOFTWARE, BOTH };
        }

        public static Handshake parse (string value) {
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
                message ("Error %s", e.message);
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

        public static AccessMode[] all () {
            return { READWRITE, READONLY, WRITEONLY };
        }

        public static AccessMode parse (string value) {
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
                message ("Error %s", e.message);
            }

            /* XXX need to return something */
            return READWRITE;
        }
    }

    /* property backing fields */
    private bool _connected = false;
    private ulong _tx_count = 0;
    private ulong _rx_count = 0;
    private uint _baud_rate = Posix.B9600;

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

    public uint baud_rate {
        get {
            return _baud_rate;
        }

        set {
            switch (value) {
                case 300:
                    _baud_rate = Posix.B300;
                    break;
                case 600:
                    _baud_rate = Posix.B600;
                    break;
                case 1200:
                    _baud_rate = Posix.B1200;
                    break;
                case 2400:
                    _baud_rate = Posix.B2400;
                    break;
                case 4800:
                    _baud_rate = Posix.B4800;
                    break;
                case 9600:
                    _baud_rate = Posix.B9600;
                    break;
                case 19200:
                    _baud_rate = Posix.B19200;
                    break;
                case 38400:
                    _baud_rate = Posix.B38400;
                    break;
                case 57600:
                    _baud_rate = Posix.B57600;
                    break;
                case 115200:
                    _baud_rate = Posix.B115200;
                    break;
                case 230400:
                    _baud_rate = Posix.B230400;
                    break;
                case 460800:
                    _baud_rate = Linux.Termios.B460800;
                    break;
                case 576000:
                    _baud_rate = Linux.Termios.B576000;
                    break;
                case 921600:
                    _baud_rate = Linux.Termios.B921600;
                    break;
                case 1000000:
                    _baud_rate = Linux.Termios.B1000000;
                    break;
                case 2000000:
                    _baud_rate = Linux.Termios.B2000000;
                    break;
                default:
                    _baud_rate = Posix.B9600;
                    break;
            }
        }
    }

    public int data_bits { get; set; default = 8; }

    public int stop_bits { get; set; default = 1; }

    public ulong non_printable { get; set; default = 0; }

    public bool echo { get; set; default = false; }

    public bool last_rx_was_cr { get; set; default = false; }

    /**
     * Private serial port specific variables.
     */
    private Posix.termios newtio;
    private Posix.termios oldtio;
    private int fd = -1;
    private GLib.IOChannel fd_channel;
    private int flags = 0;
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
    public SerialPort () {
        this.settings_changed.connect (update_settings);
    }

    /**
     * Full construction using available settings.
     */
    public SerialPort.full (string id, string device, int baud_rate,
                            int data_bits, int stop_bits, Parity parity,
                            Handshake handshake, AccessMode access_mode,
                            bool echo) {
        this.id = id;
        this.device = device;
        this.baud_rate = baud_rate;
        this.data_bits = data_bits;
        this.stop_bits = stop_bits;
        this.parity = parity;
        this.handshake = handshake;
        this.access_mode = access_mode;
        this.echo = echo;

        this.settings_changed.connect (update_settings);
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
                            this.device = iter->get_content ();
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

        this.settings_changed.connect (update_settings);
    }

    /**
     * {@inheritDoc}
     */
    public override bool open () {

        if (access_mode == AccessMode.READWRITE)
            flags = Posix.O_RDWR;
        else if (access_mode == AccessMode.READONLY)
            flags = Posix.O_RDONLY;
        else
            flags = Posix.O_WRONLY;

        /* Make non-blocking */
        if ((fd = Posix.open (device, flags | Posix.O_NONBLOCK | Posix.O_NOCTTY)) < 0) {
            fd = -1;
            return false;
        }

        /* Save the current setup */
        Posix.tcflush (fd, Posix.TCIOFLUSH);
        tcgetattr (fd, out oldtio);
        settings_changed ();
        tcsetattr (fd, Posix.TCSANOW, newtio);

        _connected = true;

        fd_channel = new GLib.IOChannel.unix_new (fd);
        source_id = fd_channel.add_watch (GLib.IOCondition.IN, this.read_bytes);

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
                message ("%s", e.message);
            }
            non_printable = 0;
            last_rx_was_cr = false;
            fd_channel = null;
            _connected = false;
            _tx_count = 0;
            _rx_count = 0;
            Posix.tcflush (fd, Posix.TCIOFLUSH);
            tcsetattr (fd, Posix.TCSANOW, newtio);//maybe change this to oldtio
            Posix.close (fd);
        }
    }

    public void flush () {
        Posix.tcflush (fd, Posix.TCIOFLUSH);
    }

    /**
     * {@inheritDoc}
     */
    public override void send_byte (uchar byte) {
        if (connected) {
            uchar[] b = new uchar[1];
            b[0] = byte;
            size_t n = Posix.write (fd, b, 1);
            _tx_count += n;
        }
    }

    /**
     * {@inheritDoc}
     */
    public override void send_bytes (char[] bytes, size_t size) {
        if (connected) {
            size_t n = Posix.write (fd, bytes, size);
            Posix.tcdrain (fd);
            _tx_count += n;
        }
    }

    /**
     * {@inheritDoc}
     */
    public override bool read_bytes (GLib.IOChannel source, GLib.IOCondition condition) {
        if (!connected)
            return false;
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
        if (echo)
            send_bytes ((char[])sized_buf, nread);

        return connected;
    }

//    /**
//     * {@inheritDoc}
//     */
//    public override string to_string () {
//        string r;
//        r  = "SerialPort [%s]\n".printf (id);
//        r += " connected:      %s\n".printf ((connected) ? "Yes" : "No");
//        r += " bytes received: %lu\n".printf (rx_count);
//        r += " bytes sent:     %lu\n".printf (tx_count);
//        r += " device:         %s\n".printf (device);
//        r += " baud rate:      %u\n".printf (baud_rate);
//        r += " data bits:      %d\n".printf (data_bits);
//        r += " stop bits:      %d\n".printf (stop_bits);
//        r += " parity:         %s\n".printf (parity.to_string ());
//        r += " handshake:      %s\n".printf (handshake.to_string ());
//        r += " access mode:    %s\n".printf (access_mode.to_string ());
//        return r;
//    }

    /**
     * Update the TTY settings.
     */
    private void update_settings () {
        Posix.cfsetospeed (ref newtio, baud_rate);
        Posix.cfsetispeed (ref newtio, baud_rate);

        /* Data bits */

        /* Will need to generate mark and space parity */
        if (data_bits == 7 && (parity == Parity.MARK || parity == Parity.SPACE))
            data_bits = 8;

        switch (data_bits) {
            case 5:
                newtio.c_cflag = (newtio.c_cflag & ~Posix.CSIZE) | Posix.CS5;
                break;
            case 6:
                newtio.c_cflag = (newtio.c_cflag & ~Posix.CSIZE) | Posix.CS6;
                break;
            case 7:
                newtio.c_cflag = (newtio.c_cflag & ~Posix.CSIZE) | Posix.CS7;
                break;
            case 8:
            default:
                newtio.c_cflag = (newtio.c_cflag & ~Posix.CSIZE) | Posix.CS8;
                break;
        }
        newtio.c_cflag |= Posix.CLOCAL | Posix.CREAD;

        /* Parity */
        newtio.c_cflag &= ~(Posix.PARENB | Posix.PARODD);
        if (parity == Parity.EVEN)
            newtio.c_cflag |= Posix.PARENB;
        else if (parity == Parity.ODD)
            newtio.c_cflag |= (Posix.PARENB | Posix.PARODD);

        newtio.c_cflag &= ~Linux.Termios.CRTSCTS;

        /* Stop Bits */
        if (stop_bits == 2)
            newtio.c_cflag |= Posix.CSTOPB;
        else
            newtio.c_cflag &= ~Posix.CSTOPB;

        /* Input settings */
        newtio.c_iflag = Posix.IGNBRK;

        /* Handshake */
        if (handshake == Handshake.SOFTWARE || handshake == Handshake.BOTH)
            newtio.c_iflag |= Posix.IXON | Posix.IXOFF;
        else
            newtio.c_iflag &= ~(Posix.IXON | Posix.IXOFF | Posix.IXANY);

        newtio.c_lflag = 0;
        newtio.c_oflag = 0;
        newtio.c_cc[Posix.VTIME] = 1;
        newtio.c_cc[Posix.VMIN] = 1;
        newtio.c_lflag &= ~(Posix.ECHONL|Posix.NOFLSH);

        int mcs=0;
        Posix.ioctl (fd, Linux.Termios.TIOCMGET, out mcs);
        mcs |= Linux.Termios.TIOCM_RTS;
        Posix.ioctl (fd, Linux.Termios.TIOCMSET, out mcs);

        if (handshake == Handshake.HARDWARE || handshake == Handshake.BOTH)
            newtio.c_cflag |= Linux.Termios.CRTSCTS;
        else
            newtio.c_cflag &= ~Linux.Termios.CRTSCTS;
    }
}
