/**
 * To compile:
 *   valac --target-glib=2.32 --pkg posix --pkg cld-0.2 --pkg gee-0.8 \
 *   --pkg libxml-2.0 --pkg comedi log.vala
 */

int main (string[] args) {

    Xml.Parser.init ();

    var xml = new Cld.XmlConfig.with_file_name ("log.xml");
    var builder = new Cld.Builder.from_xml_config (xml);

    var log = builder.get_object ("log0");
    GLib.stdout.printf ("Opening file\n");
    (log as Cld.Log).file_open ();
    GLib.stdout.printf ("Starting log thread\n");
    (log as Cld.Log).run ();

    Posix.sleep (1);

    (log as Cld.Log).stop ();
    GLib.stdout.printf ("Log thread stopped\n");
    (log as Cld.Log).file_mv_and_date (false);

    Xml.Parser.cleanup ();

    return (0);
}
