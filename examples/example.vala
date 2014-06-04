class Cld.Example : GLib.Object {

    protected string _xml = """
        <cld xmlns:cld="urn:libcld">
            <cld:objects>
                <!-- empty configuration template -->
            </cld:objects>
        </cld>
    """;

    public virtual string xml {
        get { return _xml; }
        set { _xml = value; }
    }

    protected Cld.Builder builder;

    protected Cld.Context context;

    public Example () { }

    public virtual void run () {
        Xml.Doc *doc = Xml.Parser.parse_memory (xml, xml.length);
        Xml.XPath.Context *ctx = new Xml.XPath.Context (doc);
        ctx->register_ns ("cld", "urn:libcld");
        Xml.XPath.Object *obj = ctx->eval_expression ("//cld/cld:objects");
        Xml.Node *node = obj->nodesetval->item (0);

        var config = new Cld.XmlConfig.from_node (node);

        builder = new Cld.Builder.from_xml_config (config);
        context = new Cld.Context ();

        context.objects = builder.objects;
    }
}
