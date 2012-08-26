using Cld;

int main (string[] args) {
    XmlConfig xml;
    Builder builder;

    Xml.Parser.init ();

    xml = new XmlConfig.with_file_name ("cld.xml");
    builder = new Builder.from_xml_config (xml);

    builder.print (stdout);

    Xml.Parser.cleanup ();

    return (0);
}
