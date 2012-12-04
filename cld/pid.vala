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
public class Cld.Pid : AbstractObject {

    /**
     * XXX Consider renaming Pid to PidControl to avoid any confusion with a
     *     operating system process id.
     * XXX Could add an AbstractControl type a subclass it instead.
     */

    /**
     * {@inheritDoc}
     */
    public override string id { get; set; }

    /**
     * Timestep in milliseconds to use with the thread execution.
     */
    public int dt { get; set; }

    /**
     * Proportional gain: Larger values typically mean faster response.
     */
    public double kp { get; set; }

    /**
     * Integral gain: Larger values imply steady state errors are eliminated
     * faster but can trade off with a larger overshoot.
     */
    public double ki { get; set; }

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
     * Internal thread data for control loop execution.
     */
    private unowned Thread<void *> thread;
    private Mutex mutex = new Mutex ();

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
    private Gee.Map<string, Object> _process_values;
    public Gee.Map<string, Object> process_values {
        get { return (_process_values); }
        set { update_process_values (value); }
    }

    /* XXX For now these are just analog channels, possible use digital as
        *     well later on. */
    private AIChannel pv;
    private AOChannel mv;

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
                        default:
                            break;
                    }
                } else if (iter->name == "object") {
                    if (iter->get_prop ("type") == "process_value") {
                        var pv = new ProcessValue.from_xml_node (iter);
                        process_values.set (pv.id, pv);
                    }
                }
            }
        }
    }

    /**
     * Update property backing field for process values list
     *
     * @param event Array list to update property variable
     */
    private void update_process_values (Gee.Map<string, Object> val) {
        _process_values = val;
    }

    public void add_process_value (ProcessValue pv) {
        process_values.set (pv.id, pv);
    }

    /**
     * Run the PID control loop as a thread.
     */
    public void run () {
        if (!Thread.supported ()) {
            stderr.printf ("Cannot run PID control without thread support.\n");
            running = false;
            return;
        }

        if (!running) {
            var pid_thread = new PidThread (this);

            /* Just use first available input or output channel that is found. */
            foreach (var object in process_values.values) {
                if ((object as ProcessValue).chtype == ProcessValue.Type.INPUT)
                    pv = ((object as ProcessValue).channel as AIChannel);
                else if ((object as ProcessValue).chtype == ProcessValue.Type.OUTPUT)
                    mv = ((object as ProcessValue).channel as AOChannel);
                else
                {
                    stderr.printf ("Invalid channels were provided.\n");
                    return;
                }
            }

            /* calculate the initial error values, effectively a `bumpless`
             * transfer mode */
            p_err = sp - pv.pr_scaled_value;
            /* XXX this is incorrect, it needs to divide by dt */
            d_err = pv.pr_scaled_value - pv.ppr_scaled_value;
            i_err = (mv.scaled_value - (kp * p_err) - (kd * d_err)) / ki;

            try {
                running = true;
                /* TODO create is deprecated, check compiler warnings */
                thread = Thread.create<void *> (pid_thread.run, true);
            } catch (ThreadError e) {
                stderr.printf ("%s\n", e.message);
                running = false;
                return;
            }
        }
    }

    /**
     * Stop a PID control loop that is executing.
     */
    public void stop () {
        if (running) {
            running = false;
            thread.join ();
        }
    }

    /**
     * Performs the PID calculation.
     */
    public void update () {
        stdout.printf ("(%ld) Executing PID thread every %d ms\n",
                       (long)get_monotonic_time (), dt);

        /* do the calculation */
        mutex.lock ();

        p_err = sp - pv.pr_scaled_value;
        i_err += p_err;
        d_err = pv.scaled_value - pv.pr_scaled_value;
        mv.scaled_value = (kp * p_err) + (ki * i_err) + (kd * d_err);

        /* XXX Not sure whether or not to raise an output event here, or simple
         *     write out for channel, or just let an external thread handle the
         *     output and assume that we're done. */

        mutex.unlock ();
    }

    /**
     * {@inheritDoc}
     */
    public override string to_string () {
        string str_data  = "[%s] : PID Object\n".printf (id);
               str_data += "\tSP %.3f\n".printf (sp);
               str_data += "\tKp %.3f\n".printf (kp);
               str_data += "\tKi %.3f\n".printf (ki);
               str_data += "\tKd %.3f\n".printf (kd);
        /* add iteration to print process values later during testing */
        return str_data;
    }

    /**
     * Returns the JSON representation of the object, a kind of crude first
     * pass just to try the JSON bindings, not much to it.
     *
     * @return JSON representation of the object as a string.
     */
    public string to_json () {
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
        gen.pretty = true;

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

    public class PidThread {
        unowned Pid pid;

        public PidThread (Pid pid) {
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
            return null;
        }
    }
}
