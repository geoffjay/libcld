/**
 * export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig/
 * export LD_LIBRARY_PATH=/usr/local/lib/   # maybe ?
 * valac test-builder.vala --pkg cld-0.2 --pkg gee-1.0 --pkg libxml-2.0
 **/

using Cld;

int main (string[] args) {
    var test = new App ();
    test.run ();
    return (0);
}

public class App {
    Cld.Builder builder;
    Cld.XmlConfig xml;
    Gee.Map<string, Cld.Object> channels;

    public App () {
        xml = new XmlConfig ("sample.xml");
        builder = new Builder.from_xml_config (xml);
    }

    public void run () {
        builder.print (stdout);

        channels = builder.channels;
        foreach (var channel in channels.values) {
            channel.print (stdout);
            stdout.printf ("\n");
        }

        var channel = channels.get ("do0");
        (channel as Channel).num = 10;

        builder.print (stdout);
    }
}
