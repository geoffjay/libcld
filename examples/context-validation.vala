/**
 * Sample program to illustrate Cld.Context generation and validation.
 */

class Cld.ContextValidationExample : Cld.Example {

    public override string xml {
        get { return _xml; }
        set { _xml = value; }
    }

    construct {
        xml = """
            <cld xmlns:cld="urn:libcld">
                <cld:objects>
                    <cld:object id="daq0" type="daq">
                        <cld:object id="dev0" type="device" dtype="comedi">
                            <cld:property name="type">multifunction</cld:property>
                            <cld:property name="filename">/dev/comedi1</cld:property>
                            <cld:object id="tk0" type="task" ttype="comedi">
                                <cld:property name="devref">dev0</cld:property>
                                <cld:property name="exec-type">polling</cld:property>
                                <cld:property name="subdevice">0</cld:property>
                                <cld:property name="direction">read</cld:property>
                                <cld:property name="interval-ms">100</cld:property>
                            </cld:object>
                        </cld:object>
                    </cld:object>
                    <cld:object id="log0" type="log" ltype="sqlite">
                        <cld:property name="title">Log Database</cld:property>
                        <cld:property name="path">/srv/data/</cld:property>
                        <cld:property name="file">log.db</cld:property>
                        <cld:property name="format">%Y-%m-%d_%H-%M-%S</cld:property>
                        <cld:property name="rate">0.10</cld:property>
                        <cld:property name="backup-path">/mnt/backup/</cld:property>
                        <cld:property name="backup-file">geoi-backup</cld:property>
                        <cld:property name="backup-interval-hrs">24</cld:property>
                        <cld:property name="trigger-id">ai00</cld:property>
                        <cld:object id="col00" type="column" chref="ai00"/>
                        <cld:object id="col01" type="column" chref="ai01"/>
                        <cld:object id="col02" type="column" chref="ai02"/>
                        <cld:object id="col03" type="column" chref="ai03"/>
                        <cld:object id="col04" type="column" chref="ai04"/>
                        <cld:object id="col05" type="column" chref="ai05"/>
                        <cld:object id="col06" type="column" chref="ai06"/>
                        <cld:object id="col07" type="column" chref="ai07"/>
                        <cld:object id="col08" type="column" chref="ai08"/>
                        <cld:object id="col09" type="column" chref="ai09"/>
                        <cld:object id="col10" type="column" chref="ai10"/>
                        <cld:object id="col11" type="column" chref="ai11"/>
                        <cld:object id="col12" type="column" chref="ai12"/>
                        <cld:object id="col13" type="column" chref="ai13"/>
                        <cld:object id="col14" type="column" chref="ai14"/>
                        <cld:object id="col15" type="column" chref="ai15"/>
                    </cld:object>

                    <cld:object id="cal00" type="calibration">
                        <cld:property name="units">kPa</cld:property>
                        <cld:object id="cft0" type="coefficient">
                            <cld:property name="n">0</cld:property>
                            <cld:property name="value">-25.8182</cld:property>
                        </cld:object>
                        <cld:object id="cft1" type="coefficient">
                            <cld:property name="n">1</cld:property>
                            <cld:property name="value">12.9204</cld:property>
                        </cld:object>
                    </cld:object>
                    <cld:object id="cal01" type="calibration">
                        <cld:property name="units">kPa</cld:property>
                        <cld:object id="cft0" type="coefficient">
                            <cld:property name="n">0</cld:property>
                            <cld:property name="value">-25.8500</cld:property>
                        </cld:object>
                        <cld:object id="cft1" type="coefficient">
                            <cld:property name="n">1</cld:property>
                            <cld:property name="value">12.9164</cld:property>
                        </cld:object>
                    </cld:object>
                    <cld:object id="cal02" type="calibration">
                        <cld:property name="units">kPa</cld:property>
                        <cld:object id="cft0" type="coefficient">
                            <cld:property name="n">0</cld:property>
                            <cld:property name="value">-172.4766</cld:property>
                        </cld:object>
                        <cld:object id="cft1" type="coefficient">
                            <cld:property name="n">1</cld:property>
                            <cld:property name="value">86.1306</cld:property>
                        </cld:object>
                    </cld:object>
                    <cld:object id="cal03" type="calibration">
                        <cld:property name="units">mm disp</cld:property>
                        <cld:object id="cft0" type="coefficient">
                            <cld:property name="n">0</cld:property>
                            <cld:property name="value">-12.7000</cld:property>
                        </cld:object>
                        <cld:object id="cft1" type="coefficient">
                            <cld:property name="n">1</cld:property>
                            <cld:property name="value">6.35</cld:property>
                        </cld:object>
                    </cld:object>
                    <cld:object id="cal04" type="calibration">
                        <cld:property name="units">Volts</cld:property>
                        <cld:object id="cft0" type="coefficient">
                            <cld:property name="n">0</cld:property>
                            <cld:property name="value">0.0000</cld:property>
                        </cld:object>
                        <cld:object id="cft1" type="coefficient">
                            <cld:property name="n">1</cld:property>
                            <cld:property name="value">1.0000</cld:property>
                        </cld:object>
                    </cld:object>
                    <cld:object id="cal05" type="calibration">
                        <cld:property name="units">Volts</cld:property>
                        <cld:object id="cft0" type="coefficient">
                            <cld:property name="n">0</cld:property>
                            <cld:property name="value">0.0000</cld:property>
                        </cld:object>
                        <cld:object id="cft1" type="coefficient">
                            <cld:property name="n">1</cld:property>
                            <cld:property name="value">1.0000</cld:property>
                        </cld:object>
                    </cld:object>
                    <cld:object id="cal06" type="calibration">
                        <cld:property name="units">Volts</cld:property>
                        <cld:object id="cft0" type="coefficient">
                            <cld:property name="n">0</cld:property>
                            <cld:property name="value">0.0000</cld:property>
                        </cld:object>
                        <cld:object id="cft1" type="coefficient">
                            <cld:property name="n">1</cld:property>
                            <cld:property name="value">1.0000</cld:property>
                        </cld:object>
                    </cld:object>
                    <cld:object id="cal07" type="calibration">
                        <cld:property name="units">Volts</cld:property>
                        <cld:object id="cft0" type="coefficient">
                            <cld:property name="n">0</cld:property>
                            <cld:property name="value">0.0000</cld:property>
                        </cld:object>
                        <cld:object id="cft1" type="coefficient">
                            <cld:property name="n">1</cld:property>
                            <cld:property name="value">1.0000</cld:property>
                        </cld:object>
                    </cld:object>
                    <cld:object id="cal08" type="calibration">
                        <cld:property name="units">Volts</cld:property>
                        <cld:object id="cft0" type="coefficient">
                            <cld:property name="n">0</cld:property>
                            <cld:property name="value">0.0000</cld:property>
                        </cld:object>
                        <cld:object id="cft1" type="coefficient">
                            <cld:property name="n">1</cld:property>
                            <cld:property name="value">1.0000</cld:property>
                        </cld:object>
                    </cld:object>
                    <cld:object id="cal09" type="calibration">
                        <cld:property name="units">Volts</cld:property>
                        <cld:object id="cft0" type="coefficient">
                            <cld:property name="n">0</cld:property>
                            <cld:property name="value">0.0000</cld:property>
                        </cld:object>
                        <cld:object id="cft1" type="coefficient">
                            <cld:property name="n">1</cld:property>
                            <cld:property name="value">1.0000</cld:property>
                        </cld:object>
                    </cld:object>
                    <cld:object id="cal10" type="calibration">
                        <cld:property name="units">Volts</cld:property>
                        <cld:object id="cft0" type="coefficient">
                            <cld:property name="n">0</cld:property>
                            <cld:property name="value">0.0000</cld:property>
                        </cld:object>
                        <cld:object id="cft1" type="coefficient">
                            <cld:property name="n">1</cld:property>
                            <cld:property name="value">1.0000</cld:property>
                        </cld:object>
                    </cld:object>
                    <cld:object id="cal11" type="calibration">
                        <cld:property name="units">Volts</cld:property>
                        <cld:object id="cft0" type="coefficient">
                            <cld:property name="n">0</cld:property>
                            <cld:property name="value">0.0000</cld:property>
                        </cld:object>
                        <cld:object id="cft1" type="coefficient">
                            <cld:property name="n">1</cld:property>
                            <cld:property name="value">1.0000</cld:property>
                        </cld:object>
                    </cld:object>
                    <cld:object id="cal12" type="calibration">
                        <cld:property name="units">Volts</cld:property>
                        <cld:object id="cft0" type="coefficient">
                            <cld:property name="n">0</cld:property>
                            <cld:property name="value">0.0000</cld:property>
                        </cld:object>
                        <cld:object id="cft1" type="coefficient">
                            <cld:property name="n">1</cld:property>
                            <cld:property name="value">1.0000</cld:property>
                        </cld:object>
                    </cld:object>
                    <cld:object id="cal13" type="calibration">
                        <cld:property name="units">Volts</cld:property>
                        <cld:object id="cft0" type="coefficient">
                            <cld:property name="n">0</cld:property>
                            <cld:property name="value">0.0000</cld:property>
                        </cld:object>
                        <cld:object id="cft1" type="coefficient">
                            <cld:property name="n">1</cld:property>
                            <cld:property name="value">1.0000</cld:property>
                        </cld:object>
                    </cld:object>
                    <cld:object id="cal14" type="calibration">
                        <cld:property name="units">Volts</cld:property>
                        <cld:object id="cft0" type="coefficient">
                            <cld:property name="n">0</cld:property>
                            <cld:property name="value">0.0000</cld:property>
                        </cld:object>
                        <cld:object id="cft1" type="coefficient">
                            <cld:property name="n">1</cld:property>
                            <cld:property name="value">1.0000</cld:property>
                        </cld:object>
                    </cld:object>
                    <cld:object id="cal15" type="calibration">
                        <cld:property name="units">Volts</cld:property>
                        <cld:object id="cft0" type="coefficient">
                            <cld:property name="n">0</cld:property>
                            <cld:property name="value">0.0000</cld:property>
                        </cld:object>
                        <cld:object id="cft1" type="coefficient">
                            <cld:property name="n">1</cld:property>
                            <cld:property name="value">1.0000</cld:property>
                        </cld:object>
                    </cld:object>
                    <cld:object id="ai00" type="channel" ref="dev0" ctype="analog" direction="input">
                        <cld:property name="tag">PT01</cld:property>
                        <cld:property name="desc">Cylinder Pressure</cld:property>
                        <cld:property name="num">0</cld:property>
                        <cld:property name="calref">cal00</cld:property>
                        <cld:property name="taskref">tk0</cld:property>
                        <cld:property name="subdevnum">0</cld:property>
                        <cld:property name="range">4</cld:property>
                    </cld:object>
                    <cld:object id="ai01" type="channel" ref="dev0" ctype="analog" direction="input">
                        <cld:property name="tag">PT02</cld:property>
                        <cld:property name="desc">Cylinder Pressure</cld:property>
                        <cld:property name="num">1</cld:property>
                        <cld:property name="calref">cal01</cld:property>
                        <cld:property name="taskref">tk0</cld:property>
                        <cld:property name="subdevnum">0</cld:property>
                        <cld:property name="range">4</cld:property>
                    </cld:object>
                    <cld:object id="ai02" type="channel" ref="dev0" ctype="analog" direction="input">
                        <cld:property name="tag">PT03</cld:property>
                        <cld:property name="desc">Bellofram Pressure</cld:property>
                        <cld:property name="num">2</cld:property>
                        <cld:property name="calref">cal02</cld:property>
                        <cld:property name="taskref">tk0</cld:property>
                        <cld:property name="subdevnum">0</cld:property>
                        <cld:property name="range">4</cld:property>
                    </cld:object>
                    <cld:object id="ai03" type="channel" ref="dev0" ctype="analog" direction="input">
                        <cld:property name="tag">LVDT</cld:property>
                        <cld:property name="desc">LVDT</cld:property>
                        <cld:property name="num">3</cld:property>
                        <cld:property name="calref">cal03</cld:property>
                        <cld:property name="taskref">tk0</cld:property>
                        <cld:property name="subdevnum">0</cld:property>
                        <cld:property name="range">4</cld:property>
                    </cld:object>
                    <cld:object id="ai04" type="channel" ref="dev0" ctype="analog" direction="input">
                        <cld:property name="tag">SC00</cld:property>
                        <cld:property name="desc">Spare Channel</cld:property>
                        <cld:property name="num">4</cld:property>
                        <cld:property name="calref">cal04</cld:property>
                        <cld:property name="taskref">tk0</cld:property>
                        <cld:property name="subdevnum">0</cld:property>
                        <cld:property name="range">4</cld:property>
                    </cld:object>
                    <cld:object id="ai05" type="channel" ref="dev0" ctype="analog" direction="input">
                        <cld:property name="tag">SC01</cld:property>
                        <cld:property name="desc">Spare Channel</cld:property>
                        <cld:property name="num">5</cld:property>
                        <cld:property name="calref">cal05</cld:property>
                        <cld:property name="taskref">tk0</cld:property>
                        <cld:property name="subdevnum">0</cld:property>
                        <cld:property name="range">4</cld:property>
                    </cld:object>
                    <cld:object id="ai06" type="channel" ref="dev0" ctype="analog" direction="input">
                        <cld:property name="tag">SC02</cld:property>
                        <cld:property name="desc">Spare Channel</cld:property>
                        <cld:property name="num">6</cld:property>
                        <cld:property name="calref">cal06</cld:property>
                        <cld:property name="taskref">tk0</cld:property>
                        <cld:property name="subdevnum">0</cld:property>
                        <cld:property name="range">4</cld:property>
                    </cld:object>
                    <cld:object id="ai07" type="channel" ref="dev0" ctype="analog" direction="input">
                        <cld:property name="tag">SC03</cld:property>
                        <cld:property name="desc">Spare Channel</cld:property>
                        <cld:property name="num">7</cld:property>
                        <cld:property name="calref">cal07</cld:property>
                        <cld:property name="taskref">tk0</cld:property>
                        <cld:property name="subdevnum">0</cld:property>
                        <cld:property name="range">4</cld:property>
                    </cld:object>
                    <cld:object id="ai08" type="channel" ref="dev0" ctype="analog" direction="input">
                        <cld:property name="tag">SC04</cld:property>
                        <cld:property name="desc">Spare Channel</cld:property>
                        <cld:property name="num">8</cld:property>
                        <cld:property name="calref">cal08</cld:property>
                        <cld:property name="taskref">tk0</cld:property>
                        <cld:property name="subdevnum">0</cld:property>
                        <cld:property name="range">4</cld:property>
                    </cld:object>
                    <cld:object id="ai09" type="channel" ref="dev0" ctype="analog" direction="input">
                        <cld:property name="tag">SC05</cld:property>
                        <cld:property name="desc">Spare Channel</cld:property>
                        <cld:property name="num">9</cld:property>
                        <cld:property name="calref">cal09</cld:property>
                        <cld:property name="taskref">tk0</cld:property>
                        <cld:property name="subdevnum">0</cld:property>
                        <cld:property name="range">4</cld:property>
                    </cld:object>
                    <cld:object id="ai10" type="channel" ref="dev0" ctype="analog" direction="input">
                        <cld:property name="tag">SC06</cld:property>
                        <cld:property name="desc">Spare Channel</cld:property>
                        <cld:property name="num">10</cld:property>
                        <cld:property name="calref">cal10</cld:property>
                        <cld:property name="taskref">tk0</cld:property>
                        <cld:property name="subdevnum">0</cld:property>
                        <cld:property name="range">4</cld:property>
                    </cld:object>
                    <cld:object id="ai11" type="channel" ref="dev0" ctype="analog" direction="input">
                        <cld:property name="tag">SC07</cld:property>
                        <cld:property name="desc">Spare Channel</cld:property>
                        <cld:property name="num">11</cld:property>
                        <cld:property name="calref">cal11</cld:property>
                        <cld:property name="taskref">tk0</cld:property>
                        <cld:property name="subdevnum">0</cld:property>
                        <cld:property name="range">4</cld:property>
                    </cld:object>
                    <cld:object id="ai12" type="channel" ref="dev0" ctype="analog" direction="input">
                        <cld:property name="tag">SC08</cld:property>
                        <cld:property name="desc">Spare Channel</cld:property>
                        <cld:property name="num">12</cld:property>
                        <cld:property name="calref">cal12</cld:property>
                        <cld:property name="taskref">tk0</cld:property>
                        <cld:property name="subdevnum">0</cld:property>
                        <cld:property name="range">4</cld:property>
                    </cld:object>
                    <cld:object id="ai13" type="channel" ref="dev0" ctype="analog" direction="input">
                        <cld:property name="tag">SC09</cld:property>
                        <cld:property name="desc">Spare Channel</cld:property>
                        <cld:property name="num">13</cld:property>
                        <cld:property name="calref">cal13</cld:property>
                        <cld:property name="taskref">tk0</cld:property>
                        <cld:property name="subdevnum">0</cld:property>
                        <cld:property name="range">4</cld:property>
                    </cld:object>
                    <cld:object id="ai14" type="channel" ref="dev0" ctype="analog" direction="input">
                        <cld:property name="tag">SC10</cld:property>
                        <cld:property name="desc">Spare Channel</cld:property>
                        <cld:property name="num">14</cld:property>
                        <cld:property name="calref">cal14</cld:property>
                        <cld:property name="taskref">tk0</cld:property>
                        <cld:property name="subdevnum">0</cld:property>
                        <cld:property name="range">4</cld:property>
                    </cld:object>
                    <cld:object id="ai15" type="channel" ref="dev0" ctype="analog" direction="input">
                        <cld:property name="tag">SC11</cld:property>
                        <cld:property name="desc">Spare Channel</cld:property>
                        <cld:property name="num">15</cld:property>
                        <cld:property name="calref">cal15</cld:property>
                        <cld:property name="taskref">tk0</cld:property>
                        <cld:property name="subdevnum">0</cld:property>
                        <cld:property name="range">4</cld:property>
                    </cld:object>
                </cld:objects>
            </cld>
        """;
    }

    public ContextValidationExample () {
        base ();
    }

    public override void run () {
        base.run ();

        stdout.printf ("\nContextValidation Example\n\n");

        context.print_ref_table (context as Container);
    }
}

int main (string[] args) {

    /*
     *Cld.Report.increase_log_level ();
     *Cld.Report.increase_log_level ();
     *Cld.Report.increase_log_level ();
     */

    var ex = new Cld.ContextValidationExample ();
    ex.run ();

    return (0);
}
