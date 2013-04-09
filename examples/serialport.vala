using Cld;

class Cld.SerialPortExample : GLib.Object {

    public static int main (string[] args) {
        var port = new SerialPort ();
        var loop = new MainLoop();

        port.id = "ser0";
        port.device = "/dev/ttyUSB0";
        port.baud_rate = 115200;
        port.new_data.connect (new_data_cb);

        /* this should really be in a unit test */

        GLib.Log.set_handler("SerialPortExample",
                             LogLevelFlags.LEVEL_DEBUG,
                             GLib.Log.default_handler);

        var parity = SerialPort.Parity.parse ("none");
        message ("Parity [none]: %s", parity.to_string ());

        parity = SerialPort.Parity.parse ("NoNe");
        message ("Parity [NoNe]: %s", parity.to_string ());

        parity = SerialPort.Parity.parse ("oDD");
        message ("Parity [oDD]: %s", parity.to_string ());

        parity = SerialPort.Parity.parse ("MaRK");
        message ("Parity [MaRK]: %s", parity.to_string ());

        parity = SerialPort.Parity.parse ("spacE");
        message ("Parity [spacE]: %s", parity.to_string ());

        /* access mode */
        message ("AccessMode [read andWrite]: %s", (SerialPort.AccessMode.parse ("read andWrite")).to_string ());
        message ("AccessMode [readWRITE]: %s", (SerialPort.AccessMode.parse ("readWRITE")).to_string ());
        message ("AccessMode [Ro]: %s", (SerialPort.AccessMode.parse ("Ro")).to_string ());
        message ("AccessMode [readOnly]: %s", (SerialPort.AccessMode.parse ("readOnly")).to_string ());
        message ("AccessMode [reaD Only]: %s", (SerialPort.AccessMode.parse ("reaD Only")).to_string ());
        message ("AccessMode [WrItE oNlY]: %s", (SerialPort.AccessMode.parse ("WrItE oNlY")).to_string ());

        message ("\n\n%s", port.to_string ());

        port.open ();

        //port.send_bytes ("0123456789".to_utf8 (), 10);
        //message ("\n\n%s", port.to_string ());

        loop.run ();

        port.close ();

        message ("\n\n%s", port.to_string ());

        return 0;
    }

    private static void new_data_cb (SerialPort port, uchar[] data, int size) {
        string received = "";

        for (int i = 0; i < size; i++) {
            unichar c = "%c".printf (data[i]).get_char ();
            string s = "%c".printf (data[i]);

            if (s.validate () && (c.isprint () || c.isspace ())) {
                /* Ignore LF if last char was CR (CRLF terminator) */
                if (!(port.last_rx_was_cr && (c == '\n'))) {
                    received += "%s".printf (s);
                }
            } else {
                port.non_printable++;
            }
        }

        message ("Received data: %s", received);
    }
}
