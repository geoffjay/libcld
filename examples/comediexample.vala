using Cld;
using Comedi;

class Cld.ComediExample : GLib.Object {

    private Cld.Object device;
    private GLib.MainLoop loop;
    private Cld.ComediDevice.Information information;
    private XmlConfig xml;
    private Builder builder;


    public ComediExample () {
        /*
         * Test basic constructor
         */
        message ("Testing simple construction method.");

        loop = new MainLoop ();

        device = new ComediDevice ();
        (device as Cld.ComediDevice).id = "dev00";
        (device as Cld.ComediDevice).filename = "/dev/comedi0";
        (device as Cld.ComediDevice).open ();
        message ((device as Cld.ComediDevice).to_string ());
        information = (device as Cld.ComediDevice).info ();
        message (information.to_string ());
        (device as Cld.ComediDevice).close ();
        message ("closed");
        device = null;
        information = null;

        /*
         * Test XML constructor
         */
        message ("Testing construction from XML method.");
        Xml.Parser.init ();
        xml = new XmlConfig.with_file_name ("comedidevice.xml");
        builder = new Builder.from_xml_config (xml);
        device = builder.get_object ("dev00");
        (device as Cld.ComediDevice).open ();
        message ((device as Cld.ComediDevice).to_string ());
        information = (device as Cld.ComediDevice).info ();
        message (information.to_string ());
        (device as Cld.ComediDevice).close ();
        message ("closed");
    }

    public void  run () {
        loop.run ();
    }
}

int main (string[] args) {
    Cld.ComediExample ex = new Cld.ComediExample ();
    ex.run ();

    return (0);
}
