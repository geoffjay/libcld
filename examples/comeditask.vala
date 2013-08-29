using Cld;

class Cld.ComediTaskExample : GLib.Object {

    private Cld.Object task0;
    private Cld.Object task1;
    private Cld.Object task2;
    private Cld.Object device;
    private Cld.Object channel;
    private Cld.Object out_chan1;
    private Cld.Object out_chan2;
    private Cld.Object out_chan3;
    private Cld.Object out_chan4;
    private Cld.Object out_chan5;

    private GLib.MainLoop loop;
    private XmlConfig xml;
    private Builder builder;

    public ComediTaskExample () {
        loop = new MainLoop ();

        /*
         * Test basic constructor
         */
//        message ("Testing simple construction method.");
//        task = new ComediTask ();
//        message ((task as ComediTask).to_string ());
//        (task as ComediTask).id = "t00";
//        (task as ComediTask).devref = "dev00";
//        device = new ComediDevice ();
//        (task as ComediTask).device = (device as ComediDevice);
//        message ((((task as ComediTask).device) as ComediDevice).to_string ());
//        (task as ComediTask).run ();
//
         /*
          * TestXML constructor
          */
        Xml.Parser.init ();
        xml = new XmlConfig.with_file_name ("comeditask.xml");
        builder = new Builder.from_xml_config (xml);

        out_chan1 = builder.get_object ("ao0");
        out_chan2 = builder.get_object ("ao1");
        out_chan3 = builder.get_object ("ao2");
        out_chan4 = builder.get_object ("ao3");
        out_chan5 = builder.get_object ("ao4");

        (out_chan1 as AOChannel).raw_value = 0.0;
        (out_chan2 as AOChannel).raw_value = 25.0;
        (out_chan3 as AOChannel).raw_value = 50.0;
        (out_chan4 as AOChannel).raw_value = 100.0;
        (out_chan5 as AOChannel).raw_value = 33.30;

        task0 = builder.get_object ("tk0");
        task1 = builder.get_object ("tk1");
        task2 = builder.get_object ("tk2");

        message (builder.to_string ());
        (task0 as ComediTask).run ();
        (task1 as ComediTask).run ();
        (task2 as ComediTask).run ();

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
