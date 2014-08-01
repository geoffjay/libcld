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
 *  Stephen Roy <sroy1966@gmail.com>
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
    private Cld.Device _device = null;

    /**
     * The sub device reference name.
     */
    public string devref { get; set; default = null; }

    /**
     * The referenced device.
     */
    public Cld.Device device {
        get {
            if (_device == null) {
                /* If the task references a parent device */
                if ((parent is Cld.ComediDevice) && (uri.contains (devref))) {
                _device = parent as Cld.ComediDevice;
                }
            }

            return _device;
        }
        set { _device = value; }
    }

    /**
     * Comedi subdevice number.
     */
    public int subdevice { get; set; }

    /**
     * Execution type.
     */
    public string exec_type { get; set; }

    /**
     * Input or output.
     */
    public string direction { get; set; }

    /**
     * Sampling interval in milliseconds.
     */
    public int interval_ms { get; set; }

    /**
     * A list of channel references.
     */
    public Gee.List<string>? chrefs { get; set; }

    /**
     * The channels that this task uses.
     */
    public Gee.Map<string, Object>? channels {
        get {
            _channels = get_children (typeof (Cld.Channel)) as Gee.TreeMap<string, Cld.Object>;

            return _channels;
        }
        set {
            /* remove all first */
            objects.unset_all (get_children (typeof (Cld.Channel)));
            objects.set_all (value);
        }
    }

    /**
     * A list of FIFOs for inter-process data transfer.
     * The data are paired a pipe name and file descriptor.
     */
    public Gee.Map<string, int>? fifos { get; set; }


    private Comedi.InstructionList instruction_list;
    private const int NSAMPLES = 10; //XXX Why is this set to 10 (Steve)??

    /**
     * Internal thread data for log file output handling.
     */
    private unowned GLib.Thread<void *> thread;
    private Mutex mutex = new Mutex ();
    private Thread task_thread;

    /**
     * Counts the total number of connected FIFOs.
     */
    private static int n_fifos = 0;
    private Cld.LogEntry entry;

    /**
     * A Comedi command fields used only with streaming acquisition.
     */
    private Comedi.Command cmd;
    private uint[] chanlist;// = new uint[16];
    /* An array to map the chanlist [] index to a channel */
    private Cld.AIChannel [] channel_array;
    private uint scan_period_nanosec;
    private static int total = 0;

    /**
     * Default construction.
     */
    construct {
        chrefs = new Gee.ArrayList<string> ();
        channels = new Gee.TreeMap<string, Object> ();
        fifos = new Gee.TreeMap<string, int> ();
        active = false;
    }

    public ComediTask () {
        id = "tk0";
        devref = "dev0";
        device = new ComediDevice ();
        exec_type = "polling";
        direction = "read";
        interval_ms = 100;
    }

    /**
     * Construction using an XML node.
     */
    public ComediTask.from_xml_node (Xml.Node *node) {
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
                        case "subdevice":
                            subdevice = int.parse (iter->get_content ());
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
                        case "chref":
                            chrefs.add (iter->get_content ());
                            break;
                        case "fifo":
                            fifos.set (iter->get_content (), -1);
                            break;
                        default:
                            break;
                    }
                }
            }
        }
    }

    /**
     * {@inheritDoc}
     */
    public override void run () {
        entry = new Cld.LogEntry ();
        /* Open fifos */
        foreach (string fname in fifos.keys) {
            if (Posix.access (fname, Posix.F_OK) == -1) {
                int res = Posix.mkfifo (fname, 0777);
                if (res != 0) {
                    Cld.error ("%s could not create fifo %s\n",id, fname);
                }
            }

            open_fifo.begin (fname, () => {
            });
        }

        if (device == null) {
            error ("Task %s has no reference to a device.", id);
        }

        /* Select execution type */
        switch (exec_type) {
            case "streaming":
                do_async ();
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
        foreach (int fd in fifos.values) {
            Posix.close (fd);
        }

        if (active) {
            active = false;
            if (exec_type == "polling") {
                thread.join ();
            }
        }
    }

    /**
     * Adds a channel to the task's list of channels.
     */
    public void add_channel (Object channel) {
        channels.set (channel.id, channel);
    }

    private async void open_fifo (string fname) {
        SourceFunc callback = open_fifo.callback;
        bool ready = false;
        ThreadFunc<void*> run = () => {
            Cld.debug ("%s is is waiting for a reader to FIFO %s",this.id, fname);
            int fd = Posix.open (fname, Posix.O_WRONLY);
            if (fd == -1) {
                Cld.debug ("%s Posix.open error: %d: %s",id, Posix.errno, Posix.strerror (Posix.errno));
            } else {
                fifos.set (fname, fd);
                Cld.debug ("ComediTask FIFO set: fd = %d, fifos.has_key(%s) = %s",
                                    fd,
                                    fname,
                                    (fifos.has_key (fname)).to_string());

                Cld.debug ("%s got a reader for fifo %s", id, fname);
                if (exec_type == "streaming") {
                    /* Write first timestamp to fifo */
                    string mess = "%s\t".printf (entry.time_as_string);
                    Posix.write (fd, mess, mess.length);
                }
            }
            Idle.add ((owned) callback);

            return null;
        };
        GLib.Thread.create<void*> (run, false);

        yield;
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
     * Asynchronous acquisition
     */
    private void do_async () {
        Comedi.loglevel (4);
        chanlist = new uint [channels.size];
        channel_array = new Cld.AIChannel [channels.size];

        //GLib.stdout.printf ("board name: %s\n", device.get_board_name ());
        (device as ComediDevice).dev.set_buffer_size (subdevice, 65536);
        scan_period_nanosec = (uint) (1e6 * (double)interval_ms);

        /* Make chanlist sequential and without gaps. XXX Need this for Advantech 1710. */
        foreach (var channel in channels.values) {
            if ((channel as Channel).num >= channels.size) {
                Cld.error ("Channel list must be sequential and with no gaps.");
                return;
            }
            chanlist[(channel as Channel).num] = Comedi.pack (
                                                             (channel as Channel).num,
                                                             (channel as Cld.AIChannel).range,
                                                             Comedi.AnalogReference.GROUND
                                                             );
            channel_array [(channel as AIChannel).num] = channel as Cld.AIChannel;
        }

//        for (int i = 0; i < channels.size; i++) {
//            var channel = channel_array [i];
//            stdout.printf ("i: %d, num: %d\n", i, (channel as Channel).num);
//        }

        int ret;
        /* This comedilib function will get us a generic timed
        * command for a particular board.  If it returns -1,
        * that's bad. */
        ret = (device as ComediDevice).dev.get_cmd_generic_timed (subdevice,
                    out cmd, channels.size, scan_period_nanosec);

        if (ret < 0) {
            message ("comedi_get_cmd_generic_timed failed");
        }

        /* Modify parts of the command */
        prepare_cmd ();

        /* Launch select thread */
        ThreadFunc<void*> run = () => {
            Cld.debug ("Asynchronous acquisition started for ComediTask %s", uri);
            do_select ();

            return null;
        };

        GLib.Thread.create<void*> (run, false);
    }

    private void prepare_cmd () {
        cmd.subdev = subdevice;

        cmd.flags = 0;//TriggerFlag.WAKE_EOS;

        cmd.start_src = TriggerSource.NOW;
        cmd.start_arg = 0;

        cmd.scan_begin_src = TriggerSource.FOLLOW;
        //cmd.scan_begin_arg = scan_period_nanosec; //nanoseconds;

    	cmd.convert_src = TriggerSource.TIMER;
	    cmd.convert_arg = (uint)((double)scan_period_nanosec / (double)channels.size);// 100000;

        cmd.scan_end_src = TriggerSource.COUNT;
        cmd.scan_end_arg = channels.size;

        cmd.stop_src = TriggerSource.NONE;//COUNT;
        cmd.stop_arg = 0;

        cmd.chanlist = chanlist;
        cmd.chanlist_len = channels.size;
    }


    public int do_select () {
        uint raw;
        bool is_physical = true;
        int device_fd = -1;
        int col = 0;
        ulong rx_count = 0;
        string mess;
        Posix.FILE outfile = Posix.FILE.open("log.out", "w");
        uint maxdata = (device as ComediDevice).dev.get_maxdata (0, 0);
        const int bufsz = 4096;
        Comedi.Range crange;
        int subdev_flags = (device as ComediDevice).dev.get_subdevice_flags (subdevice);

        device_fd = (device as ComediDevice).dev.fileno ();
        active = true;
        do_cmd ();

        outfile.printf ("%s\t", entry.time_as_string);

        while (active) {
            ushort[] buf = new ushort[bufsz];
            Posix.fd_set rdset;
            int ret;

            Posix.timeval timeout = Posix.timeval ();
            Posix.FD_ZERO (out rdset);
            Posix.FD_SET (device_fd, ref rdset);
            timeout.tv_sec = 0;
            timeout.tv_usec = 50000;
            ret = Posix.select (device_fd + 1, &rdset, null, null, timeout);

            if (ret < 0) {
                if (Posix.errno == Posix.EAGAIN) {
                    perror("read");
                }
            } else if (ret == 0) {
                stdout.printf ("hit timeout\n");
            } else if ((Posix.FD_ISSET (device_fd, rdset)) == 1) {
                ret = (int)Posix.read (device_fd, buf, bufsz);
                ulong bytes_per_sample;
                total += ret;
stdout.printf ("\nread %d %d\n", ret, total);

                if ((subdev_flags & SubdeviceFlag.LSAMPL) != 0) {
                    bytes_per_sample = sizeof (uint);
                } else {
                    bytes_per_sample = sizeof (ushort);
                }

                for (int i = 0; i < ret / bytes_per_sample; i++) {
                        raw = (ushort) buf[i];
                    //print_datum (raw, col, is_physical);
                    crange = (device as ComediDevice).dev.get_range (subdevice, col, 4);
                    foreach (var fd in fifos.values) {
                        var channel = channel_array [col];
                        (channel as AIChannel).add_raw_value (Comedi.to_phys (raw, crange, maxdata));
                        mess = "%s %.6f\t".printf (channel.uri, (channel as ScalableChannel).scaled_value);
//stdout.printf ("%s", mess);
                        Posix.write (fd, mess, mess.length);
                    }
                    outfile.printf ("%.6f\t", Comedi.to_phys (raw, crange, maxdata));
                    col++;
                    if (col == channels.size) {
                        foreach (var fd in fifos.values) {
                            mess = "\n%s\t".printf (entry.time_as_string);
//stdout.printf ("%s", mess);
                            Posix.write (fd, mess, mess.length);
                        }

                        //stdout.printf("\n%s\t", entry.time_as_string);
                        outfile.printf ("\n%s\t ", entry.time_as_string);
                        /* Increment the timestamp */
                        entry.timestamp = entry.timestamp.add_seconds ((double)interval_ms / 1000);
                        col = 0;
                    }
                }
            }
        }

        return 0;
    }

    private void do_cmd () {
        int ret;

        ret = (device as ComediDevice).dev.command_test (cmd);

        GLib.stdout.printf ("test ret = %d\n", ret);
        if (ret < 0) {
		    Comedi.perror("comedi_command_test");
            return;
        }

    	dump_cmd ();

        ret = (device as ComediDevice).dev.command_test (cmd);

        GLib.stdout.printf ("test ret = %d\n", ret);
        if (ret < 0) {
		    Comedi.perror("comedi_command_test");
		    return;
        }

    	dump_cmd ();

        ret = (device as ComediDevice).dev.command (cmd);

        GLib.stdout.printf ("test ret = %d\n", ret);
	    if (ret < 0) {
		    Comedi.perror("comedi_command");

		    return;
        }
	}

    private string cmd_src (uint src) {
        string buf = "";

        if ((src & TriggerSource.NONE) != 0) buf = "none|";
        if ((src & TriggerSource.NOW) != 0) buf = "now|";
        if ((src & TriggerSource.FOLLOW) != 0) buf = "follow|";
        if ((src & TriggerSource.TIME) != 0) buf = "time|";
        if ((src & TriggerSource.TIMER) != 0) buf = "timer|";
        if ((src & TriggerSource.COUNT) != 0) buf = "count|";
        if ((src & TriggerSource.EXT) != 0) buf = "ext|";
        if ((src & TriggerSource.INT) != 0) buf = "int|";
        if ((src & TriggerSource.OTHER) != 0) buf = "other|";

        if (Posix.strlen (buf) == 0) {
            buf = "unknown src";
        } else {
            //buf[strlen (buf)-1]=0;
        }

        return buf;
    }

    private void dump_cmd () {
        message ("subdevice:      %u", cmd.subdev);
        message ("start:      %-8s %u", cmd_src (cmd.start_src), cmd.start_arg);
        message ("scan_begin: %-8s %u", cmd_src (cmd.scan_begin_src), cmd.scan_begin_arg);
        message ("convert:    %-8s %u", cmd_src (cmd.convert_src), cmd.convert_arg);
        message ("scan_end:   %-8s %u", cmd_src (cmd.scan_end_src), cmd.scan_end_arg);
        message ("stop:       %-8s %u", cmd_src (cmd.stop_src), cmd.stop_arg);
    }

    private void print_datum (uint raw, int channel_index, bool is_physical) {
        double physical_value;
        var channel = channel_array [channel_index] as Cld.AIChannel;
        Comedi.Range crange = (device as ComediDevice).dev.get_range (
                                                                     subdevice,
                                                                     channel_index,
                                                                     channel.range
                                                                     );

        uint maxdata = (device as ComediDevice).dev.get_maxdata (0, 0);
        if (!is_physical) {
            GLib.stdout.printf ("%u ",raw);
        } else {
            physical_value = Comedi.to_phys (raw, crange, maxdata);
            GLib.stdout.printf ("%#8.6g ", physical_value);
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

        /*XXX Consider getting rid of Channel timestamps. They are nod needed if using FIFOs. */
        GLib.DateTime timestamp = new DateTime.now_local ();

        //Cld.debug ("\t\t\t\texecute_instruction_list (), get_seconds (): %.3f", timestamp.get_seconds ());
        ret = (device as ComediDevice).dev.do_insnlist (instruction_list);
        if (ret < 0)
            perror ("do_insnlist failed:");

        foreach (var channel in channels.values) {
            /*XXX Consider getting rid of Channel timestamps. They are nod needed if using FIFOs. */
            (channel as Channel).timestamp = timestamp;
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

                //Cld.debug ("Channel: %s, Raw value: %.3f", (channel as AIChannel).id, (channel as AIChannel).raw_value);
            } else if (channel is DIChannel) {
                meas = instruction_list.insns[i].data[0];
                if (meas > 0.0) {
                    (channel as DChannel).state = true;
                } else {
                    (channel as DChannel).state = false;
                }

                //Cld.debug ("Channel: %s, Raw value: %.3f", (channel as DIChannel).id, meas);
            }
        }
    }

     public void execute_polled_output () {
        Comedi.Range range;
        uint maxdata,  data;
        double val;
        /*XXX Consider getting rid of Channel timestamps. They are nod needed if using FIFOs. */
        GLib.DateTime timestamp = new DateTime.now_local ();

        foreach (var channel in channels.values) {

            /*XXX Consider getting rid of Channel timestamps. They are not needed if using FIFOs. */
            (channel as Channel).timestamp = timestamp;
            if (channel is AOChannel) {
                val = (channel as AOChannel).scaled_value;
                range = (device as ComediDevice).dev.get_range (
                        (channel as Channel).subdevnum, (channel as AOChannel).num,
                        (channel as AOChannel).range);

                maxdata = (device as ComediDevice).dev.get_maxdata ((channel as Channel).subdevnum, (channel as AOChannel).num);
                data = (uint)((val / 100.0) * maxdata);
                //Cld.debug ("%s scaled_value: %.3f, data: %u", (channel as AOChannel).id, (channel as AOChannel).scaled_value, data);
                (device as ComediDevice).dev.data_write (
                    (channel as Channel).subdevnum, (channel as AOChannel).num,
                    (channel as AOChannel).range, AnalogReference.GROUND, data);
            } else if (channel is DOChannel) {
                if ((channel as DOChannel).state)
                    data = 1;
                else
                    data = 0;
                //Cld.debug ("%s data value: %u", (channel as DOChannel).id, data);
                (device as ComediDevice).dev.data_write (
                    (channel as Channel).subdevnum, (channel as DOChannel).num,
                    0, 0, data);
            }
        }
     }

    /**
     * Write the data to fifos using the LogEntry class as a convenience for timestamping.
     */
    protected void write_fifos () {
        foreach (int fd in fifos.values) {
            entry = new Cld.LogEntry ();
            string mess = "%s\t".printf (entry.time_as_string);

            foreach (var channel in channels.values) {
                var type = channel.get_type ();
                if (type.is_a (typeof (Cld.ScalableChannel))) {
                        mess += "%s %.6f\t".printf (channel.uri, (channel as ScalableChannel).scaled_value);
                } else if (type.is_a (typeof (Cld.DChannel))) {
                    if ((channel as DChannel).state) {
                        mess += "%s %.1f\t".printf (channel.uri, 1.0);
                    } else {
                        mess += "%s %.1f\t".printf (channel.uri, 0.0);
                    }
                }
            }

            mess += "\n";
            /* Write message to fifo. */
            ssize_t w = Posix.write (fd, mess, mess.length);
        }
     }

    /**
     * A thread that is used to implement a polling task.
     */
    public class Thread {
        private ComediTask task;
        private static int64 start_time = get_monotonic_time ();
        private static int64 count = 1;

        public Thread (ComediTask task) {
            this.task = task;
        }

        /**
         *
         */
        public void * run () {
            Mutex mutex = new Mutex ();
            Cond cond = new Cond ();
            int64 end_time;

            while (task.active) {
                lock (task) {
                    task.trigger_device ();
                    task.write_fifos ();
                }

                mutex.lock ();
                try {
                    end_time = start_time + count++ * task.interval_ms * TimeSpan.MILLISECOND;
                    while (cond.wait_until (mutex, end_time))
                        ; /* do nothing */
                } finally {
                    mutex.unlock ();
                }
            }

            return null;
        }
    }
}

