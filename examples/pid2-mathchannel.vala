/**
 * Sample program to illustrate a PID control loop that uses aPid2 controller and
 * a MathChanel to represent a "plant". Note that the Pid2 also implements the DataSeries class.
 */

class Cld.Pid2Example : Cld.Example {

    public override string xml {
        get { return _xml; }
        set { _xml = value; }
    }

    public GLib.MainLoop loop;
    public Cld.Pid2 pid;
    public Cld.MathChannel input;
    public Cld.AOChannel output;
    public Cld.DataSeries dsoutput;
    public Cld.DataSeries dsinput;
    public double sp = 50;

    construct {
        xml = """
            <cld xmlns:cld="urn:libcld">
                <cld:objects>
                    <cld:object id="ac0" type="controller" ctype="automation">
                        <cld:object id="pid0" type="pid-2">
                            <cld:property name="sp">0.000</cld:property>
                            <cld:property name="dt">10</cld:property>
                            <cld:property name="kp">0.0</cld:property>
                            <cld:property name="ki">1.5</cld:property>
                            <cld:property name="kd">0.0</cld:property>
                            <cld:property name="desc">Test PID</cld:property>
                            <cld:object id="pvout" type="process_value2" dsref="/ctr0/dsout" direction="output"/>
                            <cld:object id="pvin" type="process_value2" dsref="/ctr0/dsin" direction="input"/>
                        </cld:object>
                    </cld:object>
                    <cld:object id="aout" type="channel" ctype="analog" direction="output">
                        <cld:property name="tag">OUT</cld:property>
                        <cld:property name="desc">Sample Output</cld:property>
                        <cld:property name="calref">/ctr0/cal0</cld:property>
                        <cld:property name="alias">Vctrl</cld:property>
                    </cld:object>
                    <cld:object id="cal0" type="calibration">
                        <cld:property name="units">Volts</cld:property>
                        <cld:object id="cft0" type="coefficient">
                            <cld:property name="n">0</cld:property>
                            <cld:property name="value">0.000</cld:property>
                        </cld:object>
                        <cld:object id="cft1" type="coefficient">
                            <cld:property name="n">1</cld:property>
                            <cld:property name="value">1.000</cld:property>
                        </cld:object>
                    </cld:object>
                    <cld:object id="dsin" type="dataseries">
                        <cld:property name="length">3</cld:property>
                        <cld:property name="chref">/ctr0/mc00</cld:property>
                    </cld:object>
                    <cld:object id="dsout" type="dataseries">
                        <cld:property name="length">100</cld:property>
                        <cld:property name="chref">/ctr0/aout</cld:property>
                        <cld:property name="alias">Vbuff</cld:property>
                    </cld:object>
                    <cld:object id="mc00" type="channel" ctype="calculation">
                        <cld:property name="tag">mc00</cld:property>
                        <cld:property name="expression">1 * Vbuff[25]</cld:property>
                        <cld:property name="dref">/ctr0/aout</cld:property>
                        <cld:property name="dref">/ctr0/dsout</cld:property>
                        <cld:property name="calref">/ctr0/cal0</cld:property>
                    </cld:object>
                </cld:objects>
            </cld>
        """;
    }

    public Pid2Example () {

        base ();
        loop = new GLib.MainLoop ();
    }

    public override void run () {

        base.run ();
//        stdout.printf ("\nPrinting objects..\n\n");
//        context.print_objects ();
//        stdout.printf ("\n Finished.\n\n");
//
//        stdout.printf ("\nPrinting reference table..\n\n");
//        context.print_ref_list ();
//        stdout.printf ("\n Finished.\n\n");
//
//        stdout.printf ("mc00:\n%s", context.get_object ("mc00").to_string_recursive ());
//        stdout.printf ("dsout:\n%s", context.get_object ("dsout").to_string ());
        pid = context.get_object ("pid0") as Cld.Pid2;
        input = context.get_object ("mc00") as Cld.MathChannel;
        output = context.get_object ("aout") as Cld.AOChannel;
        dsoutput = context.get_object ("dsout") as Cld.DataSeries;
        dsinput = context.get_object ("dsin") as Cld.DataSeries;
        output.raw_value = 0.0;
        pid.sp = 0;
        pid.start ();

        GLib.Timeout.add (10, output_cb);
        GLib.Timeout.add_seconds (1, start_cb);
        GLib.Timeout.add_seconds (20, quit_cb);

        loop.run ();
    }

    /* Write data to stdout */
    public bool output_cb () {
        stdout.printf ("%8.3f %8.3f %8.3f\n",
            pid.sp, output.scaled_value, input.scaled_value);

        return true;
    }

    /* change to the setpoint */
    public bool start_cb () {
        if (pid.sp == 0) {
            pid.sp = sp;
            //GLib.Timeout.add_seconds (10, toggle_cb);
        }

        return false;
    }

    public bool toggle_cb () {
        if (pid.sp == sp) {
            pid.sp = 0;
        } else if (pid.sp == 0) {
            pid.sp = sp;
        }

        return true;
    }

    public bool quit_cb () {
        //stdout.printf ("quit\n");
        pid.stop ();
        loop.quit ();

        return false;
    }
}

int main (string[] args) {

    var ex = new Cld.Pid2Example ();
    ex.run ();

    return (0);
}
