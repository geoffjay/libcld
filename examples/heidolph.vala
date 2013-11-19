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

using Cld;
using Posix;

/* This example is a quick test of the serial port connection
 * to a Heidolph RZR 2051 mixer.
 * To compile:
 * valac --pkg cld-0.2 --pkg libxml-2.0 --pkg gee-1.0 --pkg comedi --pkg posix heidolph.vala
 * To run:
 * 1) Turn on the mixer with the port connected.
 * 2) Start the program.
 * The program will set the RPM to 300 and print the torque and
 * speed to the standard output.
 */

class Cld.HeidolphExample : GLib.Object {

    public GLib.MainLoop loop = new MainLoop ();
    public string msg1 = "R300\r\n";
    public string msg2 = "r\r\n";
    public string msg3 = "m\r\n";
    public string msg4 = "R0\r\n";
    public string received = "c";
    public SerialPort port = new SerialPort ();
    public int b = 0;
    private uint source_id;

    public void run () {

        port.id = "ser0";
        port.device = "/dev/ttyUSB0";
        port.baud_rate = 9600;
        port.handshake = SerialPort.Handshake.NONE;
        port.parity = SerialPort.Parity.NONE;
        port.access_mode = SerialPort.AccessMode.READWRITE;
        port.data_bits = 8;
        port.stop_bits = 1;
        port.new_data.connect (new_data_cb);
        port.open ();
        GLib.stdout.printf ("port open?: %s\n", port.connected.to_string ());
        port.send_bytes (msg1.to_utf8 (), msg1.length);
        source_id = Timeout.add (100, write_cb);
        loop.run ();
        port.close ();
    }

    private void new_data_cb (SerialPort port, uchar[] data, int size) {

        for (int i = 0; i < size; i++) {
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
                    GLib.stdout.printf ("%d: %s", b, r);
                    b++;
                } else {
                    GLib.stdout.printf ("                 %s\n", r);
                }
                if (b > 400) {
                    port.send_bytes (msg4.to_utf8 (), msg4.length);
                    loop.quit ();
                }
                received = "";
            }
        }
    }

    private bool write_cb () {
        port.send_bytes (msg2.to_utf8 (), msg2.length);
        Posix.usleep (100000);
        port.send_bytes (msg3.to_utf8 (), msg3.length);
        return true;
    }
}

public static int main (string[] args) {

    Cld.HeidolphExample ex = new Cld.HeidolphExample ();

    ex.run ();

    return 0;
}
