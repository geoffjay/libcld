/**
 * Copyright (C) 2010 Geoff Johnson
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2.1 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 *
 * Author:
 *  Geoff Johnson <geoff.jay@gmail.com>
 */

/**
 * A control object for doing Proportional Integral Derivitive control loops.
 */
public class Cld.Pid : AbstractContainer {

    /**
     * XXX Consider renaming Pid to PidControl to avoid any confusion with a
     *     operating system process id.
     * XXX Could add an AbstractControl type a subclass it instead.
     */

    /**
     * Timestep in milliseconds to use with the thread execution.
     */
    public int dt { get; set; }

    /**
     * Proportional gain: Larger values typically mean faster response.
     */
    public double kp { get; set; }

    private double _ki;
    /**
     * Integral gain: Larger values imply that steady state errors are
     * eliminated faster but can trade off with a larger overshoot.
     */
    public double ki {
        get { return _ki; }
        set { _ki = (value == 0.0) ? 0.000001 : value; }
    }

    /**
     * Derivitive gain: Larger values decrease overshoot.
     */
    public double kd { get; set; }

    /**
     * Desired value that the PID controller works to achieve through process
     * changes to the measured variable.
     */
    public double sp { get; set; }

    /**
     * Whether or not the loop is currently running.
     */
    public bool running { get; set; default = false; }

    /**
     * A description of the PID control.
     */
    public string desc { get; set; default = "PID Control"; }

    /**
     * XXX Consider changing the three error variables to a single one that is
     *     current value of the input minus its previous value.
     * XXX On second thought, maybe not. The variable i_err is just the integral
     *     accumulator, p_err the instantaneous, and d_err is the instantaneous
     *     divided by the time step. Just making private and using internally.
     */

    /**
     * Proportional error:
     *  Pout = Kp*e(t)
     */
    private double p_err { get; set; default = 0.0; }

    /**
     * Integral error (accumulator):
     *  Iout = Ki*sum(e(t))
     */
    private double i_err { get; set; default = 0.0; }

    /**
     * Derivitive error:
     *  Dout = Kd*(e(t)/dt)
     */
    private double d_err { get; set; default = 0.0; }

    /**
     * This should only ever have two objects, one input one output, so it
     * might be unecessary to store them in a map. Possible future change.
     */
    private Gee.Map<string, Object>? _process_values = null;
    public Gee.Map<string, Object> process_values {
        get {
            if (_process_values.size == 0) {
                _process_values = get_children (typeof (Cld.ProcessValue));
            }
            return (_process_values);
        }
        set { update_process_values (value); }
    }

    /* XXX For now these are just analog channels, possible use digital as
     *     well later on. */
    private AIChannel? _pv = null;
    public AIChannel pv {
        get {
            if (_pv == null) {
                foreach (var object in process_values.values) {
                    if ((object as ProcessValue).chtype == ProcessValue.Type.INPUT) {
                        _pv = ((object as ProcessValue).channel as AIChannel);
                        break;
                    }
                }
            }
            return _pv;
        }
        set { _pv = value; }
    }

    private AOChannel? _mv = null;
    public AOChannel mv {
        get {
            if (_mv == null) {
                foreach (var object in process_values.values) {
                    if ((object as ProcessValue).chtype == ProcessValue.Type.OUTPUT) {
                        _mv = ((object as ProcessValue).channel as AOChannel);
                        break;
                    }
                }
            }
            return _mv;
        }
        set { _mv = value; }
    }

    public string? pv_id {
        get {
            return pv.id;
        }
    }

    public string? mv_id {
        get {
            return mv.id;
        }
    }

    /**
     * Available parameters provided by this control object.
     */
    public enum Parameters {
        /**
         * The deadband value ID.
         */
        DEADBAND = 0,
        /**
         * The integral accumulator I value.
         */
        I_ACCUM,
        /**
         * The Integral high limit cutoff value ID.
         */
        I_ACCUM_LIMIT_HIGH,
        /**
         * The Integral low limit cutoff value ID.
         */
        I_ACCUM_LIMIT_LOW,
        /**
         * Proportional term ID.
         */
        KP,
        /**
         * Integral term ID.
         */
        KI,
        /**
         * Derivitive term ID.
         */
        KD,
        /**
         * The output variable high limit cutoff value ID.
         */
        LIMIT_HIGH,
        /**
         * The output variable low limit cutoff value ID.
         */
        LIMIT_LOW,
        /**
         * The process variable (input/feedback) value.
         */
        PV,
        /**
         * The Ramping Exponential value ID.
         */
        RAMP_POWER,
        /**
         * The Ramping Threshold value ID.
         */
        RAMP_THRESHOLD,
        /**
         * The Setpoint value ID.
         */
        SP;

        /**
         * String representation of the constant.
         *
         * @return A string description of the constant.
         */
        public string to_string () {
            switch (this) {
                case DEADBAND:           return "Deadband";
                case I_ACCUM:            return "Integral Accumulator Value";
                case I_ACCUM_LIMIT_HIGH: return "Integral High Limit Cutoff";
                case I_ACCUM_LIMIT_LOW:  return "Integral Low Limit Cutoff";
                case KP:                 return "Proportional Term";
                case KI:                 return "Integral Term";
                case KD:                 return "Derivitive Term";
                case LIMIT_HIGH:         return "Measurement Variable High Limit Cutoff";
                case LIMIT_LOW:          return "Measurement Variable Low Limit Cutoff";
                case PV:                 return "Process Variable Value";
                case RAMP_POWER:         return "Ramping Exponential Value";
                case RAMP_THRESHOLD:     return "Ramping Threshold Value";
                case SP:                 return "Setpoint Value";
                default:                 assert_not_reached ();
            }
        }
    }

    private Mutex mutex = new Mutex ();

    /**
     * Default constructor.
     */
    public Pid () {
        id = "pid0";
        dt = 100;
        kp = 0.0;
        ki = 0.0;
        kd = 0.0;

        process_values = new Gee.TreeMap<string, Object> ();
    }

    /**
     * Alternate constructor that accepts PID constants as parameters.
     *
     * @param kp Proportional gain constant.
     * @param ki Integral gain constant.
     * @param kd Derivitive gain constant.
     */
    public Pid.with_constants (double kp, double ki, double kd) {
        id = "pid0";
        dt = 100;
        this.kp = kp;
        this.ki = ki;
        this.kd = kd;

        process_values = new Gee.TreeMap<string, Object> ();
    }

    /**
     * Construction using an xml node.
     *
     * @param node XML tree node containing configuration for a PID object.
     */
    public Pid.from_xml_node (Xml.Node *node) {
        string value;

        process_values = new Gee.TreeMap<string, Object> ();

        if (node->type == Xml.ElementType.ELEMENT_NODE &&
            node->type != Xml.ElementType.COMMENT_NODE) {
            id = node->get_prop ("id");
            /* iterate through node children */
            for (Xml.Node *iter = node->children; iter != null; iter = iter->next) {
                if (iter->name == "property") {
                    switch (iter->get_prop ("name")) {
                        case "sp":
                            value = iter->get_content ();
                            sp = double.parse (value);
                            break;
                        case "dt":
                            value = iter->get_content ();
                            dt = int.parse (value);
                            break;
                        case "kp":
                            value = iter->get_content ();
                            kp = double.parse (value);
                            break;
                        case "ki":
                            value = iter->get_content ();
                            ki = double.parse (value);
                            break;
                        case "kd":
                            value = iter->get_content ();
                            kd = double.parse (value);
                            break;
                        case "desc":
                            desc = iter->get_content ();
                            break;
                        default:
                            break;
                    }
                } else if (iter->name == "object") {
                    if (iter->get_prop ("type") == "process_value") {
                        var pv = new ProcessValue.from_xml_node (iter);
                        pv.parent = this;
                        add (pv);
                    }
                }
            }
        }
    }

    /**
     * Update property backing field for process values list
     *
     * @param val Array list to update process variables.
     */
    private void update_process_values (Gee.Map<string, Object> val) {
        _process_values = val;
    }

    /**
     * Add a process value object to be used as either the process variable for
     * feedback, or the manipulated variable that is being controlled.
     *
     * @param pv Process value to add to the control loop.
     */
    public void add_process_value (ProcessValue pv) {
        process_values.set (pv.id, pv);
    }

    public void print_process_values () {
        foreach (var process_value in process_values.values) {
            Cld.debug ("PV: %s", process_value.id);
        }
    }

    /**
     * Calculate the initial error values, effectively produces a `bumpless`
     * transfer when switched to automatic mode as part of a control loop.
     */
    public void calculate_preload_bias () {
        p_err = sp - pv.previous_value;
        /* XXX this is incorrect, it needs to divide by dt */
        i_err = (mv.scaled_value - (kp * p_err) - (kd * d_err)) / ki;
        d_err = pv.previous_value - pv.past_previous_value;
    }

    /**
     * This should - @inheritDoc - but this class doesn't use the Control yet as
     * its base class.
     */
    public void update () {
        /* do the calculation */
        mutex.lock ();

        p_err = sp - pv.previous_value;
        i_err += p_err;
        d_err = pv.current_value - pv.previous_value;

        lock (mv) {
            mv.raw_value = (kp * p_err) + (ki * i_err) + (kd * d_err);
        }

        //Cld.debug ("SP: %.2f, MV: %.2f, PV: %.2f, PVPR: %.2f, PVPPR: %.2f, Ep: %.2f, Ei: %.2f, Ed: %.2f",
        //       sp, mv.scaled_value, pv.current_value, pv.previous_value, pv.past_previous_value, p_err, i_err, d_err);

        /* XXX Not sure whether or not to raise an output event here, or simple
         *     write out for channel, or just let an external thread handle the
         *     output and assume that we're done. */

        mutex.unlock ();
    }

//    /**
//     * {@inheritDoc}
//     */
//    public override string to_string () {
//        string str_data  = "[%s] : PID Object\n".printf (id);
//               str_data += "\tSP %.3f\n".printf (sp);
//               str_data += "\tKp %.3f\n".printf (kp);
//               str_data += "\tKi %.3f\n".printf (ki);
//               str_data += "\tKd %.3f\n".printf (kd);
//        /* add iteration to print process values later during testing */
//        return str_data;
//    }

    /**
     * Returns the JSON representation of the object, a kind of crude first
     * pass just to try the JSON bindings, not much to it.
     *
     * @param pretty Control niceness of output formatting.
     *
     * @return JSON representation of the object as a string.
     */
    public string to_json (bool pretty = true) {
        Json.Builder builder = new Json.Builder ();
        Json.Generator gen = new Json.Generator ();
        Json.Node root;

        builder.begin_object ();

        builder.set_member_name ("type");
        builder.add_string_value ("pid");
        builder.set_member_name ("id");
        builder.add_string_value (id);
        builder.set_member_name ("dt");
        builder.add_double_value (dt);
        builder.set_member_name ("kp");
        builder.add_double_value (kp);
        builder.set_member_name ("ki");
        builder.add_double_value (ki);
        builder.set_member_name ("kd");
        builder.add_double_value (kd);
        builder.set_member_name ("sp");
        builder.add_double_value (sp);

        builder.end_object ();

        root = builder.get_root ();
        gen.set_root (root);
        gen.pretty = pretty;

        return gen.to_data (null);
    }

    /*
    <!-- pid control loop configuration -->
    <object id="ctl0" type="control">
        <object id="pid0" type="pid">
            <property name="sp">0.000000</property>
            <property name="kp">0.100000</property>
            <property name="ki">0.100000</property>
            <property name="kd">0.100000</property>
            <object id="pv0" type="process_value" chref="ai0"/>
            <object id="pv1" type="process_value" chref="ao0"/>
        </object>
    </object>
    */

    /**
     * Not even close to being implemented.
     *
     * @return When it's working it should return the XML node either as a
     *         string or an Xml.Node. Not sure yet.
     */
    public string to_xml () {
//        Xml.Doc *doc = new Xml.Doc ("1.0");

//        Xml.Ns *ns = new Xml.Ns (null, "", "cld");
//        ns->type = Xml.ElementType.ELEMENT_NODE;

//        Xml.Node *root = new Xml.Node (ns, "cld");
//        doc->set_root_element (root);

//        root->new_prop ("property", "value");

        Xml.Node *root = new Xml.Node (null, "object");
        root->new_prop ("id", id);
        root->new_prop ("type", "pid");

        /* this should just be retrieved from the  */
        Xml.Node *subnode = root->new_text_child (null, "property", "");
        subnode->new_prop ("name", "sp");
        subnode->new_prop ("name", "kp");
        subnode->new_prop ("name", "ki");
        subnode->new_prop ("name", "kd");

//        delete doc;
        return root->get_content ();
    }

    public class Thread {

        private Pid pid;

        public Thread (Pid pid) {
            this.pid = pid;
        }

        public void * run () {
            Mutex mutex = new Mutex ();
            Cond cond = new Cond ();
#if HAVE_GLIB232
            int64 end_time;
#else
            TimeVal next_time = TimeVal ();
            next_time.get_current_time ();
#endif

            Cld.debug ("PID run called");

            while (pid.running) {
                pid.update ();

                /* XXX add if DEBUG later for this
                stdout.printf ("%ld, %ld, %ld\n",
                               (long)get_monotonic_time (),
                               (long)TimeSpan.SECOND,
                               (long)TimeSpan.MILLISECOND);
                */
                mutex.lock ();
#if HAVE_GLIB232
                end_time = get_monotonic_time () + pid.dt * TimeSpan.MILLISECOND;
                while (cond.wait_until (mutex, end_time))
#else
                next_time.add (pid.dt * (long)TimeSpan.MILLISECOND);
                while (cond.timed_wait (mutex, next_time))
#endif
                    ; /* do nothing */
                mutex.unlock ();
            }

            Cld.debug ("PID run thread complete");

            return null;
        }
    }
}


/**
 * An alternate control object for doing Proportional Integral Derivitive control loops.
 */
public class Cld.Pid2 : AbstractContainer {

    /**
     * XXX Consider renaming Pid to PidControl to avoid any confusion with a
     *     operating system process id.
     * XXX Could add an AbstractControl type a subclass it instead.
     */

    /**
     * Timestep in milliseconds to use with the thread execution.
     */
    public int dt { get; set; }

    /**
     * Proportional gain: Larger values typically mean faster response.
     */
    public double kp { get; set; }

    private double _ki;
    /**
     * Integral gain: Larger values imply that steady state errors are
     * eliminated faster but can trade off with a larger overshoot.
     */
    public double ki {
        get { return _ki; }
        set { _ki = (value == 0.0) ? 0.00000 : value; }
    }

    /**
     * Derivitive gain: Larger values decrease overshoot.
     */
    public double kd { get; set; }

    /**
     * Desired value that the PID controller works to achieve through process
     * changes to the measured variable.
     */
    public double sp { get; set; }

    /**
     * Set point channel (so_channel) reference string.
     **/
    public string sp_chref { get; set; }

    /**
     * A channel that alters the setpoint value (sp) thus a time varying signal
     * can be the set point value.
     **/
    public weak ScalableChannel? sp_channel {
        get {
            var channels = get_children (typeof (Cld.ScalableChannel));
            foreach (var channel in channels.values) {

                return channel as Cld.ScalableChannel;
            }

            return null;
        }
        set {
            objects.unset_all (get_children (typeof (Cld.ScalableChannel)));
            objects.set (value.id, value);
        }
    }

    /**
     * Whether or not the loop is currently running.
     */
    public bool running { get; set; default = false; }

    /**
     * A description of the PID control.
     */
    public string desc { get; set; default = "PID Control"; }

    /**
     * The output variable high limit cutoff value ID.
     */
    public double limit_high { get; set; default = 100; }
    /**
     * The output variable low limit cutoff value ID.
     */
    public double limit_low { get; set; default = 0; }


    /**
     * XXX Consider changing the three error variables to a single one that is
     *     current value of the input minus its previous value.
     * XXX On second thought, maybe not. The variable i_err is just the integral
     *     accumulator, p_err the instantaneous, and d_err is the instantaneous
     *     divided by the time step. Just making private and using internally.
     */

    /**
     * Proportional error:
     *  Pout = Kp*e(t)
     */
    private double p_err { get; set; default = 0.0; }

    /**
     * Integral error (accumulator):
     *  Iout = Ki*sum(e(t))
     */
    private double i_err { get; set; default = 0.0; }

    /**
     * Derivitive error:
     *  Dout = Kd*(e(t)/dt)
     */
    private double d_err { get; set; default = 0.0; }

    /**
     * This should only ever have two objects, one input one output, so it
     * might be unecessary to store them in a map. Possible future change.
     */
    private Gee.Map<string, Object>? _process_values = null;
    public Gee.Map<string, Object> process_values {
        get {
            if (_process_values.size == 0) {
                _process_values = get_children (typeof (Cld.ProcessValue2));
            }

            return (_process_values);
        }
        set { update_process_values (value); }
    }

    /*
     * A DataSeries is used to store the current and two previous values of input.
     */
    private DataSeries? _pv = null;
    public DataSeries pv {
        get {
            if (_pv == null) {
                var x = process_values;
                foreach (var object in process_values.values) {
                    if ((object as ProcessValue2).chtype == ProcessValue2.Type.INPUT) {
                        _pv = ((object as ProcessValue2).dataseries as DataSeries);
                        break;
                    }
                }
            }
            return _pv;
        }
        set { _pv = value; }
    }

    private DataSeries? _mv = null;
    public DataSeries mv {
        get {
            if (_mv == null) {
                foreach (var object in process_values.values) {
                    if ((object as ProcessValue2).chtype == ProcessValue2.Type.OUTPUT) {
                        _mv = ((object as ProcessValue2).dataseries as DataSeries);
                        break;
                    }
                }
            }
            return _mv;
        }
        set { _mv = value; }
    }


    public string? pv_id {
        get {
            return pv.id;
        }
    }

    public string? mv_id {
        get {
            return mv.id;
        }
    }

    /**
     * Available parameters provided by this control object.
     */
    public enum Parameters {
        /**
         * The deadband value ID.
         */
        DEADBAND = 0,
        /**
         * The integral accumulator I value.
         */
        I_ACCUM,
        /**
         * The Integral high limit cutoff value ID.
         */
        I_ACCUM_LIMIT_HIGH,
        /**
         * The Integral low limit cutoff value ID.
         */
        I_ACCUM_LIMIT_LOW,
        /**
         * Proportional term ID.
         */
        KP,
        /**
         * Integral term ID.
         */
        KI,
        /**
         * Derivitive term ID.
         */
        KD,
        /**
         * The output variable high limit cutoff value ID.
         */
        LIMIT_HIGH,
        /**
         * The output variable low limit cutoff value ID.
         */
        LIMIT_LOW,
        /**
         * The process variable (input/feedback) value.
         */
        PV,
        /**
         * The Ramping Exponential value ID.
         */
        RAMP_POWER,
        /**
         * The Ramping Threshold value ID.
         */
        RAMP_THRESHOLD,
        /**
         * The Setpoint value ID.
         */
        SP;

        /**
         * String representation of the constant.
         *
         * @return A string description of the constant.
         */
        public string to_string () {
            switch (this) {
                case DEADBAND:           return "Deadband";
                case I_ACCUM:            return "Integral Accumulator Value";
                case I_ACCUM_LIMIT_HIGH: return "Integral High Limit Cutoff";
                case I_ACCUM_LIMIT_LOW:  return "Integral Low Limit Cutoff";
                case KP:                 return "Proportional Term";
                case KI:                 return "Integral Term";
                case KD:                 return "Derivitive Term";
                case LIMIT_HIGH:         return "Measurement Variable High Limit Cutoff";
                case LIMIT_LOW:          return "Measurement Variable Low Limit Cutoff";
                case PV:                 return "Process Variable Value";
                case RAMP_POWER:         return "Ramping Exponential Value";
                case RAMP_THRESHOLD:     return "Ramping Threshold Value";
                case SP:                 return "Setpoint Value";
                default:                 assert_not_reached ();
            }
        }
    }

    private Mutex mutex = new Mutex ();

    construct {
        process_values = new Gee.TreeMap<string, Object> ();
    }

    /**
     * Default constructor.
     */
    public Pid2 () {
        id = "pid0";
        dt = 100;
        kp = 0.0;
        ki = 0.0;
        kd = 0.0;
    }

    /**
     * Alternate constructor that accepts PID constants as parameters.
     *
     * @param kp Proportional gain constant.
     * @param ki Integral gain constant.
     * @param kd Derivitive gain constant.
     */
    public Pid2.with_constants (double kp, double ki, double kd) {
        id = "pid0";
        dt = 100;
        this.kp = kp;
        this.ki = ki;
        this.kd = kd;
    }

    /**
     * Construction using an xml node.
     *
     * @param node XML tree node containing configuration for a PID object.
     */
    public Pid2.from_xml_node (Xml.Node *node) {

        string value;

        if (node->type == Xml.ElementType.ELEMENT_NODE &&
            node->type != Xml.ElementType.COMMENT_NODE) {
            id = node->get_prop ("id");
            /* iterate through node children */
            for (Xml.Node *iter = node->children; iter != null; iter = iter->next) {
                if (iter->name == "property") {
                    switch (iter->get_prop ("name")) {
                        case "sp":
                            value = iter->get_content ();
                            sp = double.parse (value);
                            break;
                        case "dt":
                            value = iter->get_content ();
                            dt = int.parse (value);
                            break;
                        case "kp":
                            value = iter->get_content ();
                            kp = double.parse (value);
                            break;
                        case "ki":
                            value = iter->get_content ();
                            ki = double.parse (value);
                            break;
                        case "kd":
                            value = iter->get_content ();
                            kd = double.parse (value);
                            break;
                        case "desc":
                            desc = iter->get_content ();
                            break;
                        case "sp_chref":
                            sp_chref = iter->get_content ();
                            break;
                        default:
                            break;
                    }
                } else if (iter->name == "object") {
                    if (iter->get_prop ("type") == "process_value2") {
                        var pv = new ProcessValue2.from_xml_node (iter);
                        pv.parent = this;
                        add (pv);
                    }
                }
            }
        }
    }

    /**
     * Connect the setpoint channel if it exists.
     */
    public void connect_sp () {
        if (sp_channel != null) {
            (sp_channel as ScalableChannel).new_value.connect ((id, scaled_value) => {
               sp = scaled_value;
            });
        }
    }

    /**
     * Update property backing field for process values list
     *
     * @param val Array list to update process variables.
     */
    private void update_process_values (Gee.Map<string, Object> val) {
        _process_values = val;
    }

    /**
     * Add a process value object to be used as either the process variable for
     * feedback, or the manipulated variable that is being controlled.
     *
     * @param pv Process value to add to the control loop.
     */
    public void add_process_value (ProcessValue pv) {
        process_values.set (pv.id, pv);
    }

    public void print_process_values () {
        foreach (var process_value in process_values.values) {
            Cld.debug ("PV: %s", process_value.id);
        }
    }

    /**
     * Calculate the initial error values, effectively produces a `bumpless`
     * transfer when switched to automatic mode as part of a control loop.
     */
    public void calculate_preload_bias () {
        double current_value;
        double previous_value;
        double past_previous_value;

        pv.get_nth_value (0, out current_value);
        pv.get_nth_value (1, out previous_value);
        pv.get_nth_value (2, out past_previous_value);

        p_err = sp - previous_value;
        if (ki != 0) {
                i_err = ((mv.channel as AOChannel).scaled_value - (kp * p_err) - (kd * d_err)) / ki;
        } else {
            i_err = 0;
        }
        d_err = (previous_value - past_previous_value) / dt;
    }

    /**
     * This should - @inheritDoc - but this class doesn't use the Control yet as
     * its base class.
     */
    public void update () {
        /* do the calculation */
        mutex.lock ();
        double current_value;
        double previous_value;
        double past_previous_value;

        pv.get_nth_value (0, out current_value);
        pv.get_nth_value (1, out previous_value);
        pv.get_nth_value (2, out past_previous_value);

        p_err = sp - previous_value;
        i_err += p_err * dt;
        d_err = (current_value - previous_value) / dt;

        lock (mv) {
        /* Anti-windup technique. See http://www.controlguru.com/2008/021008.html */
        if ((mv.channel as AOChannel).scaled_value > limit_high) {
            (mv.channel as AOChannel).raw_value = limit_high;
            if (ki != 0) {
                    i_err = ((mv.channel as AOChannel).scaled_value - (kp * p_err) - (kd * d_err)) / ki;
            } else {
                i_err = 0;
            }
        } else if ((mv.channel as AOChannel).scaled_value < limit_low) {
            (mv.channel as AOChannel).raw_value = limit_low;
            if (ki != 0) {
                    i_err = ((mv.channel as AOChannel).scaled_value - (kp * p_err) - (kd * d_err)) / ki;
            } else {
                i_err = 0;
            }
        /* Set the output */
        }
            (mv.channel as AOChannel).raw_value = (kp * p_err) + (ki * i_err) + (kd * d_err);
        }

        //Cld.debug ("SP: %.2f, MV: %.2f, PV: %.2f, PVPR: %.2f, PVPPR: %.2f, Ep: %.2f, Ei: %.2f, Ed: %.2f",
        //       sp, mv.scaled_value, pv.current_value, pv.previous_value, pv.past_previous_value, p_err, i_err, d_err);

        /* XXX Not sure whether or not to raise an output event here, or simple
         *     write out for channel, or just let an external thread handle the
         *     output and assume that we're done. */

        mutex.unlock ();
    }

//    /**
//     * {@inheritDoc}
//     */
//    public override string to_string () {
//        string str_data  = "[%s] : PID Object\n".printf (id);
//               str_data += "\tSP %.3f\n".printf (sp);
//               str_data += "\tKp %.3f\n".printf (kp);
//               str_data += "\tKi %.3f\n".printf (ki);
//               str_data += "\tKd %.3f\n".printf (kd);
//        /* add iteration to print process values later during testing */
//        return str_data;
//    }

    /**
     * Returns the JSON representation of the object, a kind of crude first
     * pass just to try the JSON bindings, not much to it.
     *
     * @param pretty Control niceness of output formatting.
     *
     * @return JSON representation of the object as a string.
     */
    public string to_json (bool pretty = true) {
        Json.Builder builder = new Json.Builder ();
        Json.Generator gen = new Json.Generator ();
        Json.Node root;

        builder.begin_object ();

        builder.set_member_name ("type");
        builder.add_string_value ("pid");
        builder.set_member_name ("id");
        builder.add_string_value (id);
        builder.set_member_name ("dt");
        builder.add_double_value (dt);
        builder.set_member_name ("kp");
        builder.add_double_value (kp);
        builder.set_member_name ("ki");
        builder.add_double_value (ki);
        builder.set_member_name ("kd");
        builder.add_double_value (kd);
        builder.set_member_name ("sp");
        builder.add_double_value (sp);

        builder.end_object ();

        root = builder.get_root ();
        gen.set_root (root);
        gen.pretty = pretty;

        return gen.to_data (null);
    }

    /*
    <!-- pid control loop configuration -->
    <object id="ctl0" type="control">
        <object id="pid0" type="pid">
            <property name="sp">0.000000</property>
            <property name="kp">0.100000</property>
            <property name="ki">0.100000</property>
            <property name="kd">0.100000</property>
            <object id="pv0" type="process_value" chref="ai0"/>
            <object id="pv1" type="process_value" chref="ao0"/>
        </object>
    </object>
    */

    /**
     * Not even close to being implemented.
     *
     * @return When it's working it should return the XML node either as a
     *         string or an Xml.Node. Not sure yet.
     */
    public string to_xml () {
//        Xml.Doc *doc = new Xml.Doc ("1.0");

//        Xml.Ns *ns = new Xml.Ns (null, "", "cld");
//        ns->type = Xml.ElementType.ELEMENT_NODE;

//        Xml.Node *root = new Xml.Node (ns, "cld");
//        doc->set_root_element (root);

//        root->new_prop ("property", "value");

        Xml.Node *root = new Xml.Node (null, "object");
        root->new_prop ("id", id);
        root->new_prop ("type", "pid");

        /* this should just be retrieved from the  */
        Xml.Node *subnode = root->new_text_child (null, "property", "");
        subnode->new_prop ("name", "sp");
        subnode->new_prop ("name", "kp");
        subnode->new_prop ("name", "ki");
        subnode->new_prop ("name", "kd");

//        delete doc;
        return root->get_content ();
    }

    public class Thread {

        private Pid2 pid;

        public Thread (Pid2 pid) {
            this.pid = pid;
        }

        public void * run () {
            Mutex mutex = new Mutex ();
            Cond cond = new Cond ();
#if HAVE_GLIB232
            int64 end_time;
#else
            TimeVal next_time = TimeVal ();
            next_time.get_current_time ();
#endif

            Cld.debug ("PID run called");

            while (pid.running) {
                pid.update ();

                /* XXX add if DEBUG later for this
                stdout.printf ("%ld, %ld, %ld\n",
                               (long)get_monotonic_time (),
                               (long)TimeSpan.SECOND,
                               (long)TimeSpan.MILLISECOND);
                */
                mutex.lock ();
#if HAVE_GLIB232
                end_time = get_monotonic_time () + pid.dt * TimeSpan.MILLISECOND;
                while (cond.wait_until (mutex, end_time))
#else
                next_time.add (pid.dt * (long)TimeSpan.MILLISECOND);
                while (cond.timed_wait (mutex, next_time))
#endif
                    ; /* do nothing */
                mutex.unlock ();
            }

            Cld.debug ("PID run thread complete");

            return null;
        }
    }
}

