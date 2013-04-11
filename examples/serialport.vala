using Cld;

class Cld.SerialPortExample : GLib.Object {

    public string received = "";

    public void run () {
        var port = new SerialPort ();
        var loop = new MainLoop();

        port.id = "ser0";
        port.device = "/dev/ttyUSB0";
        port.baud_rate = 115200;
        port.handshake = SerialPort.Handshake.HARDWARE;

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

        //string prog = "( RS232 ( Sources ( \"CO2A W\" \"CO2B W\" \"H2OA W\" \"H2OB W\" \"P kPA\" Diag ) )";
        //prog += "( Poll Now )";
        //prog += "( Rate 50Hz )";
        //prog += "( Timestamp None )";
        //prog += "( CheckSum Off )";
        //prog += "( Baud 115200 ) )\r\n";

        //string prog = "( Reboot Now )\r\n";

        //port.send_bytes (prog.to_utf8 (), prog.length);
        //message ("\n\n%s", prog);
        message ("\n\n%s", port.to_string ());

        loop.run ();

        port.close ();

        message ("\n\n%s", port.to_string ());
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
                foreach (string token in tokens) {
                    r += "%s,".printf (token);
                }
                r = r.substring (0, r.length - 1);
                stdout.printf ("%s\n", r);
                received = "";
            }
        }
    }
}

public static int main (string[] args) {

    Cld.SerialPortExample ex = new Cld.SerialPortExample ();

    ex.run ();

    return 0;
}
