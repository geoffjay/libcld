using Cld;

int main (string[] args) {
    var test = new App ();
    test.run ();
    return (0);
}

public class App {
    Cld.Builder builder;
    Cld.XmlConfig xml;

    public App () {
        xml = new XmlConfig ("sample.xml");
        builder = new Builder.from_xml_config (xml);
    }

    public void run () {
        builder.print (stdout);
    }
}
