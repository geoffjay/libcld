using Cld;

class Cld.SocketPortExample : GLib.Object {

    public string received = "";

    public void run () {
        var loop = new MainLoop();

        var xml = """
            <object id="sock0"
                    type="port"
                    ptype="socket">
                <property name="host">10.0.1.77</property>
                <property name="port">502</property>
            </object>
        """;

        Xml.Doc *doc = Xml.Parser.parse_memory (xml, xml.length);
        Xml.XPath.Context *ctx = new Xml.XPath.Context (doc);
        Xml.XPath.Object *obj = ctx->eval_expression ("//object");
        Xml.Node *node = obj->nodesetval->item (0);

        var port = new SocketPort.from_xml_node (node);
        assert (port != null);

        port.new_data.connect (new_data_cb);

        /* this should really be in a unit test */

        message ("\n\n%s", port.to_string ());

        port.open ();

//        string command = "test";
//        port.send_bytes (command.to_utf8 (), command.length);
        char[] command = new char[12];
        command[0]  = 0x00;
        command[1]  = 0x00;
        command[2]  = 0x00;
        command[3]  = 0x00;
        command[4]  = 0x00;
        command[5]  = 0x06;
        command[6]  = 0x98;
        command[7]  = 0x03;
        command[8]  = 0x00;
        command[9]  = 0x10;
        command[10] = 0x00;
        command[11] = 0x10;
        port.send_bytes (command, 12);
        message ("\n\n%s", port.to_string ());

        loop.run ();

        port.close ();

        message ("\n\n%s", port.to_string ());
    }

    private void new_data_cb (SocketPort port, uchar[] data, int size) {

        for (int i = 0; i < size; i++) {
            unichar c = "%c".printf (data[i]).get_char ();
            string s = "%c".printf (data[i]);

            if (!(c == '\n')) {
                received += "%s".printf (s);
            }

            //if (c == '\n') {
            //    stdout.printf ("%s\n", received);
            //    received = "";
            //}
        }

        foreach (var c in received.to_utf8 ()) {
            stdout.printf ("%X\n", c);
        }
        stdout.printf ("\n\n");

        message ("\n\n%s", port.to_string ());

        //stdout.printf ("%s\n", received);
        received = "";
    }
}

public static int main (string[] args) {

    Cld.SocketPortExample ex = new Cld.SocketPortExample ();

    ex.run ();

    return 0;
}
