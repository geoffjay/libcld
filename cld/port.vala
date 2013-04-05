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
 * A common interface for port type objects like serial ports. Much of the ideas
 * here are from the moserial application SerialConnection class.
 */
[GenericAccessors]
public interface Cld.Port : Cld.Object {

    public enum LineEnd {
        CRLF,
        CR,
        LF,
        TAB,
        ESC,
        NONE;

        public string to_string () {
            switch (this) {
                case CRLF: return "CR+LF end";
                case CR:   return "CR end";
                case LF:   return "LF end";
                case TAB:  return "TAB end";
                case ESC:  return "ESC end";
                case NONE: return "No end";
                default:   assert_not_reached ();
            }
        }

        public LineEnd[] all () {
            return { CRLF, CR, LF, TAB, ESC, NONE };
        }

        public LineEnd parse (string value) {
            try {
                var regex_crlf = new Regex ("cr(+|&)*lf", RegexCompileFlags.CASELESS);
                var regex_cr   = new Regex ("cr", RegexCompileFlags.CASELESS);
                var regex_lf   = new Regex ("lf", RegexCompileFlags.CASELESS);
                var regex_tab  = new Regex ("tab", RegexCompileFlags.CASELESS);
                var regex_esc  = new Regex ("esc", RegexCompileFlags.CASELESS);
                var regex_none = new Regex ("none", RegexCompileFlags.CASELESS);

                if (regex_crlf.match (value)) {
                    return CRLF;
                } else if (regex_cr.match (value)) {
                    return CR;
                } else if (regex_lf.match (value)) {
                    return LF;
                } else if (regex_tab.match (value)) {
                    return TAB;
                } else if (regex_esc.match (value)) {
                    return ESC;
                } else if (regex_none.match (value)) {
                    return NONE;
                }
            } catch (RegexError e) {
                debug ("Error %s\n", e.message);
            }

            /* XXX need to return something */
            return CRLF;
        }

        public string value () {
            switch (this) {
                case CRLF: return "\r\n";
                case CR:   return "\r";
                case LF:   return "\n";
                case TAB:  return "\t";
                case ESC:  return "\x1b";
                case NONE: return "";
                default:   assert_not_reached ();
            }
        }
    }

    /**
     * Read-only flag to tell if the port is connected.
     */
    public abstract bool connected { get; }

    /**
     * Read-only count of bytes transmitted.
     */
    public abstract ulong tx_count { get; }

    /**
     * Read-only count of bytes received.
     */
    public abstract ulong rx_count { get; }

    /**
     * Read-only string containing RX and TX totals
     */
    public abstract string byte_count_string { owned get; }

    /**
     * Connect to the port device using the parameters in the object that
     * implements this interface.
     *
     * @return ``true`` or ``false`` depending on whether or not the port
     *         connection attempt was successful.
     */
    public abstract bool open ();

    /**
     * Disconnect the port device.
     */
    public abstract void close ();

    /**
     * Transmit a single byte over the port.
     *
     * @param byte Single byte to send.
     */
    public abstract void send_byte (uchar byte);

    /**
     * Transmit an array of bytes over the port.
     *
     * @param bytes Array of bytes to send.
     */
    public abstract void send_bytes (char[] bytes, size_t size);

    /**
     * Receive an array of bytes over the port.
     *
     * @param source File descriptor to read over.
     * @param condition Not entirely sure at this point.
     */
    public abstract bool read_bytes (GLib.IOChannel source, GLib.IOCondition condition);
}
