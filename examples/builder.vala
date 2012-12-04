using Cld;
using Posix;

int main (string[] args) {
    XmlConfig xml;
    Builder builder;
    Cld.Object pid;
    Cld.Object log;

    Xml.Parser.init ();

    xml = new XmlConfig.with_file_name ("cld.xml");
    builder = new Builder.from_xml_config (xml);

    builder.print (GLib.stdout);

    var channel = builder.get_object ("ai0");
    GLib.stdout.printf ("ai0 device:\n\n%s\n\n%s\n",
                        (channel as Channel).device.to_string (),
                        (channel as AChannel).calibration.to_string ()
                       );

    (channel as AIChannel).raw_value_list_size = 10;
    (channel as AIChannel).add_raw_value (1.0);
    (channel as AIChannel).add_raw_value (2.0);
    (channel as AIChannel).add_raw_value (3.0);

    log = builder.get_object ("log0");
    (log as Cld.Log).file_open ();
    (log as Cld.Log).run ();

    pid = builder.get_object ("pid0");
    (pid as Cld.Pid).run ();
    sleep (1);
    (pid as Cld.Pid).stop ();

    (log as Cld.Log).stop ();
    (log as Cld.Log).file_mv_and_date (false);

    GLib.stdout.printf ("\njson:\n\n%s\n", (pid as Cld.Pid).to_json ());
    GLib.stdout.printf ("\nxml:\n\n%s\n", (pid as Cld.Pid).to_xml ());

    Xml.Parser.cleanup ();

    return (0);
}
