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
    * Abstract properties
    */
    public override bool active { get; set; }
    public override string id { get; set; }
    public string devref { get; set; }
    public Device device { get; set; }
    public string exec_type { get; set; }
    public int subdevice { get; set; }
    public string poll_type { get; set; }
    public int poll_interval_ms { get; set; }

    private Gee.Map<string, Object>? _channels = null;
    public Gee.Map<string, Object>? channels {
            get { return _channels; }
            set { _channels = value; }
    }

    /**
     * Internal thread data for log file output handling.
     */
    private unowned GLib.Thread<void *> thread;
    private Mutex mutex = new Mutex ();
    private ReadThread task_thread;


    /**
     * Constructors
     **/
    public ComediTask () {
        active = false;
        id = "tk0";
        devref = "dev00";
        device = new ComediDevice ();
        exec_type = "polling";
        subdevice = 0;
        poll_type = "read";
        poll_interval_ms = 100;
    }

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
                        case "exec-type":
                            exec_type = iter->get_content ();
                            break;
                        case "subdevice":
                            subdevice = int.parse (iter->get_content ());
                            break;
                        case "poll-type":
                            poll_type = iter->get_content ();
                            break;
                        case "poll-interval-ms":
                            poll_interval_ms = int.parse (iter->get_content ());
                            break;
                        default:
                            break;
                    }
                }
            }
        }
    }

    public override string to_string () {
        string str_data  = "Cld.ComediTask\n";
               str_data += " [id  ] : %s\n".printf (id);
               str_data += " [devref] : %s\n".printf (devref);
               str_data += " [exec_type] : %s\n".printf (exec_type);
               str_data += " [subdevice] : %d\n".printf (subdevice);
               str_data += " [poll_type] : %s\n".printf (poll_type);
               str_data += " [poll_interval_ms] : %d\n".printf (poll_interval_ms);
        return str_data;
    }


    /**
     * Abstract methods
     */
    public override void run () {
        if (device == null)
            error ("Task %s has no reference to a device.", id);
        if (!(device as ComediDevice).is_open)
            (device as ComediDevice).open ();
        if (!(device as ComediDevice).is_open)
            error ("Failed to open Comedi device: %s", devref);
            switch (exec_type) {
                    case "streaming":
                        /* XXX TBD */
                        break;
                    case "polling":
                        switch (poll_type) {
                            case "read":
                                do_polled_read ();
                                break;
                            case "write":
                                //do_polled_write ();
                                break;
                            default:
                                break;
                        }
                        break;
                    default:
                        break;
            }
    }

    public override void stop () {
       device.close ();
       if ((device as ComediDevice).is_open) {
        message ("Failed to close Comedi device: %s", devref);
       }
    }

    private void do_polled_read () {
        // setup the device instruction list based on channel list and subdevice
        message ("doin' the polled read");
        (device as ComediDevice).set_insn_list (channels, subdevice);
        if (!GLib.Thread.supported ()) {
            stderr.printf ("Cannot run logging without thread support.\n");
            active = false;
            return;
        }
        if (!active) {
            task_thread = new ReadThread (this);

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

    private void trigger_device () {
        (device as ComediDevice).test ();
    }
    public class ReadThread {
        private ComediTask task;

        public ReadThread (ComediTask task) {
            this.task = task;
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

            while (task.active) {
                lock (task) {
                    task.trigger_device ();
                }

                mutex.lock ();
                try {
#if HAVE_GLIB232
                    end_time = get_monotonic_time () + task.poll_interval_ms * TimeSpan.MILLISECOND;
                    while (cond.wait_until (mutex, end_time))
#else
                    next_time.add (task.poll_interval_ms * (long)TimeSpan.MILLISECOND);
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

