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

using Comedi;

/**
 * An task object that uses a Comedi device.
 */

public class Cld.ComediTask : AbstractTask {

   /**
    * Property backing fields.
    */
    private Gee.Map<string, Object>? _channels = null;

   /**
    * {@inheritDoc}
    */
    public override bool active { get; set; }

   /**
    * {@inheritDoc}
    */
    public override string id { get; set; }

   /**
    * The sub device reference name.
    */
    public string devref { get; set; }

    /**
     * The referenced subdevice.
     */
    public Device device { get; set; }

   /**
    * ...
    */
    public string exec_type { get; set; }

   /**
    * ...
    */
    public string direction { get; set; }

   /**
    * ...
    */
    public int interval_ms { get; set; }

   /**
    * ...
    */
    public Gee.Map<string, Object>? channels {
        get { return _channels; }
        set { _channels = value; }
    }

    private Comedi.InstructionList instruction_list;
    private const int NSAMPLES = 10; //XXX Why is this set to 10 (Steve)??

    /**
     * Internal thread data for log file output handling.
     */
    private unowned GLib.Thread<void *> thread;
    private Mutex mutex = new Mutex ();
    private Thread task_thread;

    /**
     * Default construction.
     */
    public ComediTask () {
        active = false;
        id = "tk0";
        devref = "dev0";
        device = new ComediDevice ();
        exec_type = "polling";
        direction = "read";
        interval_ms = 100;

        channels = new Gee.TreeMap<string, Object> ();
    }

    /**
     * Construction using an XML node.
     */
    public ComediTask.from_xml_node (Xml.Node *node) {
        active = false;
        if (node->type == Xml.ElementType.ELEMENT_NODE &&
            node->type != Xml.ElementType.COMMENT_NODE) {
            id = node->get_prop ("id");

            /* Iterate through node children */
            for (Xml.Node *iter = node->children;
            iter != null; iter = iter->next) {
                if (iter->name == "property") {
                    switch (iter->get_prop ("name")) {
                        case "devref":
                            devref = iter->get_content ();
                            break;
                        case "exec-type":
                            exec_type = iter->get_content ();
                            break;
                        case "direction":
                            direction = iter->get_content ();
                            break;
                        case "interval-ms":
                            interval_ms = int.parse (iter->get_content ());
                            break;
                        default:
                            break;
                    }
                }
            }
        }

        channels = new Gee.TreeMap<string, Object> ();
    }

    /**
     * {@inheritDoc}
     */
    public override string to_string () {

        string str_data = "[%s  ] : Comedi task\n".printf (id);
               str_data += "      [devref] : %s\n".printf (devref);
               str_data += "      [exec_type] : %s\n".printf (exec_type);
               str_data += "      [direction] : %s\n".printf (direction);
               str_data += "      [interval_ms] : %d\n".printf (interval_ms);
               str_data += "      [channels.size] : %d\n".printf (channels.size);
        return str_data;
    }

    /**
     * {@inheritDoc}
     */
    public override void run () {
        if (device == null)
            error ("Task %s has no reference to a device.", id);

        switch (exec_type) {
            case "streaming":
                /* XXX TBD */
                break;
            case "polling":
                switch (direction) {
                    case "read":
                        direction = "read";
                        break;
                    case "write":
                        direction = "write";
                        break;
                    default:
                        break;
                }
                do_polling ();
                break;
            default:
                break;
        }
    }

    /**
     * {@inheritDoc}
     */
    public override void stop () {
        if (active) {
            active = false;
            thread.join ();
        }
    }

    /**
     * Adds a channel to the task's list of channels.
     */
    public void add_channel (Object channel) {
        channels.set (channel.id, channel);
    }

    /**
     * Polling tasks spawn a thread of execution. Currently, a task is either input (read)
     * or output (write) though it could be possible to have a combination of the two
     * operating in a single task.
     */
    private void do_polling () {

        switch (direction) {
            case "read":
                // setup the device instruction list based on channel list and device
                set_insn_list ();
                break;
            case "write":
                // no action required for now.
                break;
            default:
                break;
        }
        // Instantiate and launch the thread.
        if (!GLib.Thread.supported ()) {
            stderr.printf ("Cannot run polling without thread support.\n");
            active = false;
            return;
        }

        if (!active) {
            task_thread = new Thread (this);

            try {
                active = true;
                thread = GLib.Thread.create<void *> (task_thread.run, true);
            } catch (ThreadError e) {
                stderr.printf ("%s\n", e.message);
                active = false;
                return;
            }
        }
    }

    /**
     * Build a Comedi instruction list for a single subdevice
     * from a list of channels.
     **/
    public void set_insn_list () {
        Instruction[] instructions = new Instruction [channels.size];
        int n = 0;

        instruction_list.n_insns = channels.size;

        foreach (var channel in channels.values) {
            instructions[n]                 = Instruction ();
            instructions[n].insn            = InstructionAttribute.READ;
            instructions[n].data            = new uint [NSAMPLES];
            instructions[n].subdev          = (channel as Channel).subdevnum;

            if (channel is AIChannel) {
                instructions[n].chanspec    = pack (n, (channel as AIChannel).
                                                    range, AnalogReference.GROUND);
                instructions[n].n            = NSAMPLES;
            } else if (channel is DIChannel) {
                instructions[n].chanspec     = pack (n, 0, 0);
                instructions[n].n            = 1;
            }
            n++;
        }

        instruction_list.insns = instructions;
    }

    /**
     * Here again the task is input (read) or output (write)
     * exclusively but that could change as needed.
     */
    private void trigger_device () {
        switch (direction) {
            case "read":
                execute_instruction_list ();
                break;
            case "write":
                execute_polled_output ();
                break;
            default:
                break;
        }
    }

    /**
     * This method executes a Comedi Instruction list.
     */
    public void execute_instruction_list () {
        Comedi.Range range;
        uint maxdata;
        int ret, i = 0, j;
        double meas;

        ret = (device as ComediDevice).dev.do_insnlist (instruction_list);
        if (ret < 0)
            perror ("do_insnlist failed:");

        foreach (var channel in channels.values) {
            maxdata = (device as ComediDevice).dev.get_maxdata (
                        (channel as Channel).subdevnum, (channel as Channel).num);

            /* Analog Input */
            if (channel is AIChannel) {

                meas = 0.0;
                for (j = 0; j < NSAMPLES; j++) {
                    range = (device as ComediDevice).dev.get_range (
                        (channel as Channel).subdevnum, (channel as Channel).num,
                        (channel as AIChannel).range);

                    //message ("range min: %.3f, range max: %.3f, units: %u", range.min, range.max, range.unit);
                    meas += Comedi.to_phys (instruction_list.insns[i].data[j], range, maxdata);
                    //message ("instruction_list.insns[%d].data[%d]: %u, physical value: %.3f", i, j, instruction_list.insns[i].data[j], meas/(j+1));
                }

                meas = meas / (j);
                (channel as AIChannel).add_raw_value (meas);
                //Cld.debug ("Channel: %s, Raw value: %.3f\n", (channel as AIChannel).id, (channel as AIChannel).raw_value);
                i++;
            } else if (channel is DIChannel) {

                meas = instruction_list.insns[i].data[0];
                if (meas > 0.0)
                    (channel as DChannel).state = true;
                else
                    (channel as DChannel).state = false;
                //Cld.debug ("Channel: %s, Raw value: %.3f\n", (channel as DIChannel).id, meas);
                i++;
            }
        }
     }

     public void execute_polled_output () {
        Comedi.Range range;
        uint maxdata,  data;
        double val;

        foreach (var channel in channels.values) {

            if (channel is AOChannel) {
                val = (channel as AOChannel).scaled_value;
                range = (device as ComediDevice).dev.get_range (
                        (channel as Channel).subdevnum, (channel as AOChannel).num,
                        (channel as AOChannel).range);

                maxdata = (device as ComediDevice).dev.get_maxdata ((channel as Channel).subdevnum, (channel as AOChannel).num);
                data = (uint)((val / 100.0) * maxdata);
                //Cld.debug ("%s scaled_value: %.3f, data: %u\n", (channel as AOChannel).id, (channel as AOChannel).scaled_value, data);
                (device as ComediDevice).dev.data_write (
                    (channel as Channel).subdevnum, (channel as AOChannel).num,
                    (channel as AOChannel).range, AnalogReference.GROUND, data);
            } else if (channel is DOChannel) {
                if ((channel as DOChannel).state)
                    data = 1;
                else
                    data = 0;
                //Cld.debug ("%s data value: %u\n", (channel as DOChannel).id, data);

                (device as ComediDevice).dev.data_write (
                    (channel as Channel).subdevnum, (channel as DOChannel).num,
                    0, 0, data);
            }
        }
     }


    /**
     * A thread that is used to implement a polling task.
     */
    public class Thread {
        private ComediTask task;

        public Thread (ComediTask task) {
            this.task = task;
        }

        /**
         *
         */
        public void * run () {
            Mutex mutex = new Mutex ();
            Cond cond = new Cond ();
#if HAVE_GLIB232
            int64 end_time;
#else
            TimeVal next_time = TimeVal ();
            next_time.get_current_time ();
#endif

            while (task.active) {
                lock (task) {
                    task.trigger_device ();
                }

                mutex.lock ();
                try {
#if HAVE_GLIB232
                    end_time = get_monotonic_time () + task.interval_ms * TimeSpan.MILLISECOND;
                    while (cond.wait_until (mutex, end_time))
#else
                    next_time.add (task.interval_ms * (long)TimeSpan.MILLISECOND);
                    while (cond.timed_wait (mutex, next_time))
#endif
                        ; /* do nothing */
                } finally {
                    mutex.unlock ();
                }
            }

            return null;
        }
    }
}

