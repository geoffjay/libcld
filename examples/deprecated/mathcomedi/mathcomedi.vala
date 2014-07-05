/*
 * Compile with
 * valac --pkg cld-0.2 --pkg libxml-2.0 --pkg comedi --pkg gee-1.0 --pkg libmatheval mathcomedi.vala
 *
 */

using Cld;
using Math;
//using matheval;


class MathComediExample : GLib.Object {

public GLib.MainLoop loop;
public XmlConfig xml;
public Builder builder;
public Cld.Object ai0;
public Cld.Object ai1;
public Cld.Object ai2;
public Cld.Object ai3;
public Cld.Object ao0;
public Cld.Object ao1;
public Cld.Object ao2;
public Cld.Object ao3;
public Cld.Object ao4;
public Cld.Object ao5;
public Cld.Object vc0;

int n = 0;
int T = 100;
int length = 100 * T;

   public void run () {
        Cld.ComediDevice.Information information;

        loop = new MainLoop();
        Cld.verbosity = 1;
        Xml.Parser.init ();
        xml = new XmlConfig.with_file_name ("mathcomedi.xml");
        builder = new Builder.from_xml_config (xml);
        message ("BUILDER:\n%s\n", builder.to_string ());
        var dev0 = builder.get_object ("dev0");
        var dev1 = builder.get_object ("dev1");
        (dev0 as ComediDevice).open ();
        (dev1 as ComediDevice).open ();
        information = (dev0 as Cld.ComediDevice).info ();
        Cld.debug ("%s\n", information.to_string ());
        information = (dev1 as Cld.ComediDevice).info ();
        Cld.debug ("%s\n", information.to_string ());
        ai0 = builder.get_object ("ai0");
        ai1 = builder.get_object ("ai1");
        ai2 = builder.get_object ("ai2");
        ai3 = builder.get_object ("ai3");
        ao0 = builder.get_object ("ao0");
        ao1 = builder.get_object ("ao1");
        ao2 = builder.get_object ("ao2");
        ao3 = builder.get_object ("ao3");
//        ao4 = builder.get_object ("ao4");
//        ao5 = builder.get_object ("ao5");
        vc0 = builder.get_object ("vc0");

        (((dev0 as ComediDevice).get_object ("tk0")) as ComediTask).run ();
        (((dev1 as ComediDevice).get_object ("tk0")) as ComediTask).run ();
//        (((dev1 as ComediDevice).get_object ("tk1")) as ComediTask).run ();

        GLib.Timeout.add (100, update_cb);
        GLib.Timeout.add (100, update_output_cb);

        loop.run ();
    }

    private bool update_output_cb () {

        (ao0 as AOChannel).raw_value = 10 * sin (6 * GLib.Math.PI * n / T) + 50;
        (ao1 as AOChannel).raw_value = 10 * sin (8 * GLib.Math.PI * n / T) + 50;
        (ao2 as AOChannel).raw_value = 10 * sin (10 * GLib.Math.PI * n / T) + 50;
        (ao3 as AOChannel).raw_value = 10 * (vc0 as VChannel).calculated_value;
//        (ao4 as AOChannel).raw_value = 80;
//        (ao5 as AOChannel).raw_value = 100;

        return true;
    }

    private bool update_cb () {
        n++;
        if (n > T) {
            Cld.debug ("\nfinished\n");
            loop.quit ();

            return false;
        } else {
            Cld.debug ("ai0: %.2f ai1: %.2f ai2: %.2f ai3: %.2f " +
                       "ao0: %.2f ao1: %.2f ao2: %.2f ao3: %.2f vc0: %.2f\n",
                                      (ai0 as ScalableChannel).scaled_value,
                                      (ai1 as ScalableChannel).scaled_value,
                                      (ai2 as ScalableChannel).scaled_value,
                                      (ai3 as ScalableChannel).scaled_value,
                                      (ao0 as ScalableChannel).scaled_value,
                                      (ao1 as ScalableChannel).scaled_value,
                                      (ao2 as ScalableChannel).scaled_value,
                                      (ao3 as ScalableChannel).scaled_value,
                                      (vc0 as VChannel).calculated_value);
            return true;
        }
    }

    public void print_out_cb () {
        // connects to new value () signal
    }
}

public static int main (string[] main) {
Xml.Parser.init ();
MathComediExample ex = new MathComediExample ();
ex.run ();
Xml.Parser.cleanup ();

return 0;
}

