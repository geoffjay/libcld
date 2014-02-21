/*
 * Compile with
 * valac --pkg cld-0.2 --pkg libxml-2.0 --pkg comedi --pkg gee-1.0 --pkg libmatheval mathcomedi.vala
 *
 */

using Cld;
using matheval;

class MathComediExample : GLib.Object {

    public void run () {
        Cld.verbosity = 1;
        var builder = new Builder.from_file ("mathcomedi.xml");
        message ("BUILDER:\n%s\n", builder.to_string ());
        //var ai1 = builder.getobject

        //get the channels and set the expression
        //setup a timer to report values
        //start tasks running
    }

    public void print_out_cb () {
        // connects to new value () signal
    }

    public static int main (string[] main) {
    Xml.Parser.init ();
    MathComediExample ex = new MathComediExample ();
    ex.run ();
    Xml.Parser.cleanup ();

    return 0;
    }
}

