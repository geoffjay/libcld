/**
 * export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig
 * valac --pkg gee-1.0 --pkg cld-0.2 --pkg libxml-2.0 math.vala
 */
using Cld;

class Cld.Operator: GLib.Object {

    public char val { get; set; }

    public Operator(char o) {
        val = o;
    }
}

class Cld.Operand: GLib.Object {

    public string val { get; set; }

    public Operand(string o) {
        val = o;
    }
}

class Cld.MathExample: GLib.Object {

    private Channel cha; 
    private Gee.LinkedList<Cld.Operator> operator;
    private Gee.LinkedList<Cld.Operand> operand;

    private char[] tokens;

    public MathExample () {

        /* Initialize stacks */
        operator = new Gee.LinkedList<Cld.Operator> ();
        operand = new Gee.LinkedList<Cld.Operand> ();

        /* Pre-split the expression */
        // equation is 1+2*3/4-5
        tokens = {'1', '+', '2', '*', '3', '/', '4', '-', '5', '\n'};
    }

    public void populate() {

        // equation is 1+2*3/4-5
        operator.add(new Cld.Operator('+'));
        operator.add(new Cld.Operator('*'));
        operator.add(new Cld.Operator('/'));
        operator.add(new Cld.Operator('-'));

        operand.add(new Cld.Operand("1"));
        operand.add(new Cld.Operand("2"));
        operand.add(new Cld.Operand("3"));
        operand.add(new Cld.Operand("4"));
        operand.add(new Cld.Operand("5"));
    }

    public AIChannel instantiate_VChannel() {
        AIChannel channel; 

        var xml = """
            <object id="ai0"
            type="channel"
            ref="dev0"
            ctype="analog"
            direction="input">
            <property name="tag">IN0</property>
            <property name="desc">Test Input</property>
            <property name="num">0</property>
            <property name="calref">cal0</property>
            </object>
            """;

        Xml.Doc *doc = Xml.Parser.parse_memory (xml, xml.length);
        Xml.XPath.Context *ctx = new Xml.XPath.Context (doc);
        Xml.XPath.Object *obj = ctx->eval_expression ("//object");
        Xml.Node *node = obj->nodesetval->item (0);

        channel = new AIChannel.from_xml_node (node);

        channel.raw_value = 5D;

        return channel;
    }

    public double eval_expression(string expr) {
        if (expr.length == 0)
            return 0D;

        return (double) expr.length;
    }

    public void run () {

        populate();
        test_poll();

        cha = instantiate_VChannel();

        string expr = "1+2+3+4+5";

        double result = eval_expression( expr );

        stdout.printf("Result is %f.\n", result);

        /*populate ();*/
        /*instantiate_VChannel ();*/ 

    }

    public void test_poll() {
        Cld.Operand tail = operand.peek_tail();
        Cld.Operand head = operand.peek_head();

        string t = tail.val;
        string h = head.val;

        stdout.printf("tail is %s\n", t);
        stdout.printf("head is %s\n", h);
    }
}

public static int main (string[] args) {

    print("Starting...\n");
    Cld.MathExample ex = new Cld.MathExample ();

    ex.run ();

    print("Finished.\n");
    return 0;
}
