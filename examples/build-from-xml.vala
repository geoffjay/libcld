/**
 * Sample program to illustrate asynchronous data acquisition using a Comedi
 * device.
 */

class Cld.BuildFromXmlExample : Cld.Example {

    public override string xml {
        get { return _xml; }
        set { _xml = value; }
    }

    construct {
        xml = """
            <cld xmlns:cld="urn:libcld">
                <cld:objects>
                    <cld:object id="daqctl0" type="controller" ctype="acquisition">
                        <cld:object id="dev0" type="device" driver="comedi">
                            <cld:property name="hardware">PCI-1713</cld:property>
                            <cld:property name="type">input</cld:property>
                            <cld:property name="file">/dev/comedi0</cld:property>
                            <cld:object id="tk0" type="task" ttype="comedi">
                                <cld:property name="exec-type">polling</cld:property>
                                <cld:property name="subdevice">0</cld:property>
                                <cld:property name="direction">read</cld:property>
                                <cld:property name="interval-ms">100</cld:property>
                                <cld:object id="tkch0" type="channel" chref="ai0"/>
                            </cld:object>
                            <cld:object id="tk1" type="task" ttype="comedi">
                                <cld:property name="exec-type">polling</cld:property>
                                <cld:property name="subdevice">1</cld:property>
                                <cld:property name="direction">write</cld:property>
                                <cld:property name="interval-ms">100</cld:property>
                            </cld:object>
                        </cld:object>
                    </cld:object>

                    <cld:object id="logctl0" type="controller" ctype="log">
                        <cld:object id="log0" type="log" ltype="csv">
                            <cld:property name="title">Data Log</cld:property>
                            <cld:property name="path">./</cld:property>
                            <cld:property name="file">log.dat</cld:property>
                            <cld:property name="format">%F-%T</cld:property>
                            <cld:property name="rate">10.000</cld:property>
                            <cld:object id="col0" type="column" chref="ai0"/>
                        </cld:object>
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

                    <cld:object id="ai0" type="channel" ref="dev0" ctype="analog" direction="input">
                        <cld:property name="tag">IN0</cld:property>
                        <cld:property name="desc">Sample Input</cld:property>
                        <cld:property name="num">0</cld:property>
                        <cld:property name="calref">cal0</cld:property>
                        <cld:property name="taskref">tk0</cld:property>
                    </cld:object>

                    <cld:object id="ao0" type="channel" ref="dev0" ctype="analog" direction="output">
                        <cld:property name="tag">OUT0</cld:property>
                        <cld:property name="desc">Output1</cld:property>
                        <cld:property name="num">0</cld:property>
                        <cld:property name="calref">cal0</cld:property>
                        <cld:property name="taskref">tk1</cld:property>
                    </cld:object>

                    <cld:object id="ao1" type="channel" ref="dev0" ctype="analog" direction="output">
                        <cld:property name="tag">OUT1</cld:property>
                        <cld:property name="desc">Output2</cld:property>
                        <cld:property name="num">1</cld:property>
                        <cld:property name="calref">cal0</cld:property>
                        <cld:property name="taskref">tk1</cld:property>
                    </cld:object>

                    <!-- Heidolph -->
                    <cld:object id="ser0" type="port" ptype="serial">
                        <cld:property name="device">/dev/ttyUSB0</cld:property>
                        <cld:property name="baudrate">9600</cld:property>
                        <cld:property name="databits">8</cld:property>
                        <cld:property name="stopbits">1</cld:property>
                        <cld:property name="parity">none</cld:property>
                        <cld:property name="handshake">none</cld:property>
                        <cld:property name="accessmode">rw</cld:property>
                        <cld:property name="echo">false</cld:property>
                    </cld:object>
                    <cld:object id="hm0" type="module" mtype="heidolph">
                        <cld:property name="port">ser0</cld:property>
                    </cld:object>
                    <cld:object id="heidolph00" type="channel" ctype="virtual">
                        <cld:property name="tag">HEIDOLPH_SPEED</cld:property>
                        <cld:property name="desc">Speed</cld:property>
                        <cld:property name="num">0</cld:property>
                        <cld:property name="calref">cal0</cld:property>
                    </cld:object>
                    <cld:object id="heidolph01" type="channel" ctype="virtual">
                        <cld:property name="tag">HEIDOLPH_TORQUE</cld:property>
                        <cld:property name="desc">Torque</cld:property>
                        <cld:property name="num">1</cld:property>
                        <cld:property name="calref">cal0</cld:property>
                    </cld:object>

                    <cld:object id="autoctrl0" type="controller" ctype="automation">
                        <cld:object id="ctl0" type="control">
                            <cld:object id="pid0" type="pid">
                                <cld:property name="desc">PID0</cld:property>
                                <cld:property name="dt">10</cld:property>
                                <cld:property name="sp">0.000000</cld:property>
                                <cld:property name="kp">0.000000</cld:property>
                                <cld:property name="ki">0.020000</cld:property>
                                <cld:property name="kd">0.000000</cld:property>
                                <cld:object id="pv0" type="process_value" chref="ai0"/>
                                <cld:object id="pv1" type="process_value" chref="ao0"/>
                            </cld:object>
                        </cld:object>
                        <cld:object id="ctl1" type="control">
                            <cld:object id="pid1" type="pid-2">
                                <cld:property name="desc">PID1</cld:property>
                                <cld:property name="dt">10</cld:property>
                                <cld:property name="sp">0.000000</cld:property>
                                <cld:property name="kp">0.000000</cld:property>
                                <cld:property name="ki">0.000500</cld:property>
                                <cld:property name="kd">0.000000</cld:property>
                                <cld:object id="pv0" type="process_value" chref="ds0"/>
                                <cld:object id="pv1" type="process_value" chref="ao1"/>
                            </cld:object>
                        </cld:object>
                    </cld:object>
                </cld:objects>
            </cld>
        """;
    }

    public BuildFromXmlExample () {
        base ();
    }

    public override void run () {
        base.run ();

        stdout.printf ("\nPrinting objects..\n\n");
        context.print_objects ();
        stdout.printf ("\n Finished.\n\n");

        stdout.printf ("\nPrinting reference table..\n\n");
        context.print_ref_table (context);
        stdout.printf ("\n Finished.\n\n");


        stdout.printf ("\nGenerating Context..\n\n");
        context.generate ();
        stdout.printf ("\n Finished.\n\n");

        stdout.printf ("\nParent - child list\n\n");
        //print_heritage (context);
    }

    private void print_heritage (Cld.Object object) {
        stdout.printf ("id: %s\tparent.id: %s\n", object.id, object.parent.id);
        if (object is Container) {
            if ((object as Container).objects != null) {
                foreach (var obj in (object as Container).objects.values) {
                    print_heritage (obj);
                }
            }
        }
    }
}

int main (string[] args) {

    var ex = new Cld.BuildFromXmlExample ();
    ex.run ();

    return (0);
}
