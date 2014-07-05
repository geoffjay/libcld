using Cld;

class Cld.SerialPortExample : GLib.Object {

    public string received = "";

    public void run () {
        var loop = new MainLoop();
        var xml = new XmlConfig.with_file_name ("serial.xml");
        var builder = new Builder.from_xml_config (xml);

        var port = builder.get_object ("sp0");

        (port as Cld.SerialPort).new_data.connect (new_data_cb);

        //message (port.to_string ());

        (port as Cld.SerialPort).open ();
        loop.run ();
        (port as Cld.SerialPort).close ();
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

    Xml.Parser.init ();
    Cld.SerialPortExample ex = new Cld.SerialPortExample ();
    ex.run ();
    Xml.Parser.cleanup ();

    return 0;
}
