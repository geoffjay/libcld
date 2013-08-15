using Cld;

class Cld.ComediTaskExample : GLib.Object {

    private Cld.Object task;
    private Cld.Object device;
    private GLib.MainLoop loop;
    private XmlConfig xml;
    private Builder builder;

    public ComediTaskExample () {
        loop = new MainLoop ();
        /*
         * Test basic constructor
         */
        message ("Testing simple construction method.");
        task = new ComediTask ();
        message ((task as ComediTask).to_string ());
        (task as ComediTask).id = "t00";
        (task as ComediTask).devref = "dev00";
        device = new ComediDevice ();
        (task as ComediTask).device = (device as ComediDevice);
        message ((((task as ComediTask).device) as ComediDevice).to_string ());
        (task as ComediTask).run ();
         /*
          * TestXML constructor
          */
        message ("Testing construction from XML method.");
        Xml.Parser.init ();
        xml = new XmlConfig.with_file_name ("comedidevice.xml");
        builder = new Builder.from_xml_config (xml);
        task = builder.get_object ("t00");
        (task as ComediTask).run ();

         /*
          * Test methods
          */
    }

     public void  run () {
        loop.run ();
    }
}

int main (string[] args) {
    Cld.ComediTaskExample ex = new Cld.ComediTaskExample ();
    ex.run ();

    return (0);
}
