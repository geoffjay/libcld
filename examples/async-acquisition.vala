/**
 * Sample program to illustrate asynchronous data acquisition using a Comedi
 * device.
 */

class Cld.AsyncAcquisitionExample : Cld.Example {

    public override string xml {
        get { return _xml; }
        set { _xml = value; }
    }

    construct {
        xml = """
            <cld xmlns:cld="urn:libcld">
                <cld:objects>
                    <cld:object id="daq0" type="daq">
                        <cld:property name="rate">10.0</cld:property>
                        <cld:object id="dev0" type="device" driver="comedi">
                            <cld:property name="hardware">PCI-1713</cld:property>
                            <cld:property name="type">input</cld:property>
                            <cld:property name="file">/dev/comedi0</cld:property>
                        </cld:object>
                    </cld:object>

                    <cld:object id="log0" type="log" ltype="csv">
                        <cld:property name="title">Data Log</cld:property>
                        <cld:property name="path">./</cld:property>
                        <cld:property name="file">log.dat</cld:property>
                        <cld:property name="format">%F-%T</cld:property>
                        <cld:property name="rate">10.000</cld:property>
                        <cld:object id="col0" type="column" chref="ai0"/>
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
                    </cld:object>
                </cld:objects>
            </cld>
        """;
    }

    public AsyncAcquisitionExample () {
        base ();
    }

    public override void run () {
        base.run ();

        stdout.printf ("\nAsynchronous Acquisition Example\n\n");

        var log = context.get_object ("log0");
        stdout.printf ("Log ID: %s\n", log.id);
    }
}

int main (string[] args) {

    var ex = new Cld.AsyncAcquisitionExample ();
    ex.run ();

    return (0);
}
