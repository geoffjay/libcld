using Cld;

class Cld.SocketPortExample : GLib.Object {

    public string received = "";

    public void run () {
        var loop = new MainLoop();

        var xml = """
            <object id="sock0"
                    type="port"
                    ptype="socket">
                <property name="host">127.0.0.1</property>
                <property name="port">4444</property>
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

        string command = "test";
        port.send_bytes (command.to_utf8 (), command.length);
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

            if (c == '\n') {
                stdout.printf ("%s\n", received);
                received = "";
            }
        }
    }
}

public static int main (string[] args) {

    Cld.SocketPortExample ex = new Cld.SocketPortExample ();

    ex.run ();

    return 0;
}
