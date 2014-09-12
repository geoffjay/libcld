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
 * Authors:
 *  Geoff Johnson <geoff.jay@gmail.com>
 *  Stepehen Roy <sroy1966@gmail.com>
 */

/**
 * A class with methods for managing data aquisition Device and Task objects from
 * within a Cld.Context.
 *
 * Data from multiple Task sources is combined by multiplexer which feed a data
 * to a pipe or XXX (TBD) socket.
 */
using Comedi;

public class Cld.AcquisitionController : Cld.AbstractController {
    /**
     * A collection of tasks and an ipc defines a multiplexer.
     * All of the multiplexers are in this array.
     */
    private Gee.Map<string, Multiplexer?> multiplexers;

    /**
     * The tasks that are contained in this.
     */
    private Gee.Map<string, Cld.Object> tasks;

    /**
     * The devices that are contained in this.
     */
    private Gee.Map<string, Cld.Object> devices;

    /**
     * A signal that starts streaming tasks concurrently.
     */
    public signal void async_start (GLib.DateTime start);

    /**
     * Default construction
     */
    construct {
        _objects = new Gee.TreeMap<string, Cld.Object> ();
    }

    /**
     * Construction using an xml node
     */
    public AcquisitionController.from_xml_node (Xml.Node *node) {
        string value;

        if (node->type == Xml.ElementType.ELEMENT_NODE &&
            node->type != Xml.ElementType.COMMENT_NODE) {
            _id = node->get_prop ("id");
            /* iterate through node children */
            for (Xml.Node *iter = node->children; iter != null; iter = iter->next) {
                if (iter->name == "property") {
                    switch (iter->get_prop ("name")) {
                        case "fifo":
                            fifos.set (iter->get_content (), -1);
                            break;
                        default:
                            break;
                    }
                } else if (iter->name == "object") {
                    switch (iter->get_prop ("type")) {
                        case "device":
                            if (iter->get_prop ("driver") == "comedi") {
                                var dev = new Cld.ComediDevice.from_xml_node (iter);
                                dev.parent = this;
                                try {
                                    add (dev);
                                } catch (Cld.Error.KEY_EXISTS e) {
                                    Cld.error (e.message);
                                }
                            }
                            break;
                        default:
                            break;
                    }
                }
            }
        }
    }

    public void run () {
        foreach (var task in tasks.values) {
            (task as Cld.ComediTask).run ();
        }
        var start = new GLib.DateTime.now_local ();
        async_start (start);
        foreach (var multiplexer in multiplexers.values) {
            multiplexer.stream_data ();
        }
    }


    /**
     * {@inheritDoc}
     */
    public override void generate () {
        tasks = get_object_map (typeof (Cld.ComediTask));
        devices = get_object_map (typeof (Cld.ComediDevice));

        foreach (var device in devices.values) {
            (device as Device).open ();
        }

        foreach (var task in tasks.values) {
            /* Connect this signal to enable concurrent starting of streaming tasks */
            async_start.connect ((task as Cld.ComediTask).async_start);
        }

        generate_multiplexers ();
    }

    /**
     * Update task fifo lists in preparation for logging.
     * @param log A log that is requesting data.
     * @param fname The uri of a named pipe for inter-process communication.
     */
    public void new_fifo (Cld.Log log, string fname) {

        /* Check if logged channels are from a streaming acquisition */
        foreach (var column in (log as Cld.Container).get_children (typeof (Cld.Column)).values) {
            var uri = (column as Cld.Column).channel.uri;
            var tasks = get_object_map (typeof (Cld.ComediTask));

            foreach (var task in tasks.values) {
                if (((task as Cld.ComediTask).exec_type == "streaming") &&
                        ((task as Cld.ComediTask).chrefs.contains (uri))) {
                    (task as Cld.ComediTask).fifos.set (fname, -1);
                }
            }
        }
    }

    /**
     * Combines tasks with a common named pipe to form a data multiplexer.
     */
    private void generate_multiplexers () {
        multiplexers = new Gee.TreeMap<string, Multiplexer?> ();
        Cld.AcquisitionController.Multiplexer multiplexer;

        foreach (var task in tasks.values) {

            foreach (var fname in ((task as Cld.ComediTask).fifos.keys)) {
                /* Search multiplexers for one with this fname */
                if (!(multiplexers.has_key (fname))) {
                    multiplexer = new Cld.AcquisitionController.Multiplexer ();
                } else {
                    multiplexer = multiplexers.get (fname);
                }

                var device = (task as Cld.ComediTask).device;
                var subdevice = (task as Cld.ComediTask).subdevice;
                //Comedi.Device dev = (device as Cld.ComediDevice).dev;
                var size = (device as Cld.ComediDevice).dev.get_buffer_size ((uint)subdevice);
                var fd = (device as Cld.ComediDevice).dev.fileno ();
                void *map;
                map = Posix.mmap (null, size, Posix.PROT_READ, Posix.MAP_SHARED, fd, 0);
                if (multiplexer != null) {
                    multiplexer.task_mmaps.set (task as Cld.ComediTask, map);
                    multiplexer.fname = fname;
                    multiplexer.generate ();
                    //multiplexer.start_channelizer (100);

                    multiplexers.set (fname, multiplexer);
                }
            }
        }
    }
    /**
     * Mutiplexes data from multiple tasks.
     */
    private class Multiplexer : GLib.Object {
        /* A list of task, memory map pairs */
        private Gee.Map<Cld.ComediTask, void*> _task_mmaps;
        public Gee.Map<Cld.ComediTask, void*> task_mmaps {
            get { return _task_mmaps; }
            set { _task_mmaps = value; }
        }

        /* The name that identifies an interprocess communication pipe or socket. */
        private string _fname;
        public string fname {
            get { return _fname; }
            set { _fname = value; }
        }

        /* A vector of the current binary data values of the channels */
        private ushort [] data_register;

        construct {
            task_mmaps = new Gee.TreeMap<Cld.ComediTask, ushort*> ();
        }

        public void generate () {
            int nchans = 0;

            foreach (var task in task_mmaps.keys) {
                nchans+= task.channels.size;
            }

            data_register = new ushort [nchans];
        }

        /* Set a value in the data register */
        public void set_raw (int index, ushort val) {
            lock (data_register) {
                data_register [index] = val;
            }
        }

        /* Get a value in the data register */
        public ushort get_raw (int index) {
            ushort val;

            lock (data_register) {
                val = data_register [index];
            }

            return val;
        }

        /**
         * Opens a named pipe FIFO and starts the data writing thread.
         */
        public async void stream_data () {
            open_fifo.begin ((obj, res) => {
                /* get a file descriptor */
                try {
                    int fd = open_fifo.end (res);
                    Cld.debug ("Multiplexer with fifo %s and fd %d has a reader", fname, fd);

                    bg_multiplex_data.begin (fd, (obj, res) => {
                        try {
                            bg_multiplex_data.end (res);
                            Cld.debug ("Multiplexer with fifo %s multiplex data async ended", fname);
                        } catch (ThreadError e) {
                            string msg = e.message;
                            Cld.error (@"Thread error: $msg");
                        }
                    });

                } catch (ThreadError e) {
                    string msg = e.message;
                    Cld.error (@"Thread error: $msg");
                }
            });
        }

        /**
         * Opens a FIFO for inter-process communication.
         * @param fname The path name of the named pipe.
         * @return A file descriptor for the named pipe.
         */
        private async int open_fifo () {
            SourceFunc callback = open_fifo.callback;
            int fd = -1;
            GLib.Thread<int> thread = new GLib.Thread<int> ("open_fifo", () => {
                Cld.debug ("Acquisition controller is waiting for a reader to FIFO %s", fname);
                fd = Posix.open (fname, Posix.O_WRONLY);
                if (fd == -1) {
                    Cld.debug ("%s Posix.open error: %d: %s", fname, Posix.errno, Posix.strerror (Posix.errno));
                } else {
                    Cld.debug ("Acquisition controller opening FIFO %s fd: %d", fname, fd);
                }

                Idle.add ((owned) callback);
                return  0;
            });

            yield;

            return fd;
        }

        /**
         * Multiplexes data from multiple task and writes it to a queue.
         * Also, it writes data to a FIFO for inter-process communication.
         * @param fname The path name of the named pipe.
         */
        private async void bg_multiplex_data (int fd) throws ThreadError {
            SourceFunc callback = bg_multiplex_data.callback;
            ushort word = 0;
            ushort [] b = new ushort [1];
            int total = 0;
            int i;
            bool ready = true;
            int size;                    // the number of tasks in the multiplexer
            Cld.ComediDevice [] devices; // the Comedi devices used by these tasks
            int [] nchans;               // the number of channels in each task
            int [] subdevices;           // the subdevice numbers for these devices
            int [] buffersizes;          // the data buffer sizes of each subdevice
            int [] nscans;               // the integral number of scans that are available in a data buffer
            int nscan = int.MAX;         // the integral number of scans that will be multiplexed
            ushort* [] maps;             // an array of pointers to memory mapped data for these subdevices


            size = task_mmaps.size;
            devices = new Cld.ComediDevice [size];
            nchans = new int [size];
            subdevices = new int [size];
            buffersizes = new int [size];
            nscans = new int [size];
            maps = new void* [size];

            i = 0;
            foreach (var task in task_mmaps.keys) {
                var device = (task as Cld.ComediTask).device;
                var subdevice = (task as Cld.ComediTask).subdevice;
                //Comedi.Device dev = (device as Cld.ComediDevice).dev;

                devices [i] = (task as ComediTask).device as Cld.ComediDevice;
                nchans [i] = (task as ComediTask).channels.size;
                subdevices [i] = (task as ComediTask).subdevice;
                buffersizes [i] = (devices [i] as Cld.ComediDevice).dev.get_buffer_size (subdevices [i]);
                maps [i] = task_mmaps.get (task);
                i++;
            }

            GLib.Thread<int> thread = new GLib.Thread<int> ("%s_multiplex_data".printf (fname),  () => {

                while (true) {
                    /* Determine the minimum integral size data required for multiplexing */
                    nscan = int.MAX;
                    for (i = 0; i < size; i++) {
                        int buffer_contents = (devices [i] as Cld.ComediDevice).dev.get_buffer_contents (subdevices [i]);
                        if (buffer_contents >= buffersizes [i] / 2) {
                            stdout.printf ("Buffer [%d] overflow: %d\n", i, buffer_contents);
                        }
                        nscans [i] = buffer_contents / nchans [i];
                        nscan = nscan < nscans [i] ? nscan : nscans [i];
                    }

                    /* scans */
                    for (i = 0; i < nscan; i++) {

                        int raw_index = 0; // index of the raw channel number of the multiplexer

                        /* tasks */
                        for (int j = 0; j < size; j++) {
                            /* channels */
                            for (int k = 0; k < nchans [j]; k++) {
                                //word = *(maps [j] + ((k + i * nchans [j]) % buffersizes [j]));
                                word = *(maps [j] + (k + i * nchans [j]));
                                //stdout.printf (" %4X ", word);
                                /* Write the raw value to a register */
                                set_raw (raw_index,  word);

                                /* Write the data to the fifo */
                                b [0] = word;
                                Posix.write (fd, b, 2);

                                raw_index++;
                                total++;
if ((total % 32768) == 0) {
    stdout.printf ("%d: total written to multiplexer: %d\n",
    (int) Linux.gettid (), total);
}
                            }
                        }
                        //stdout.printf ("\n");
                    }

                    /* mark buffers as read */
                    if ((nscan) > 0) {
                        for (i = 0; i < size; i++) {
                            (devices [i] as Cld.ComediDevice).dev.mark_buffer_read (subdevices [i], nscan * nchans [i]);
                        }
                    }
                    Thread.usleep (10000);
                }

                Idle.add ((owned) callback);
                return 0;
            });

            yield;
        }

        /**
         * Update the Cld.Channel values
         */
        public void start_channelizer (int channel_refresh_ms) {

            GLib.Timeout.add_full (GLib.Priority.DEFAULT_IDLE, channel_refresh_ms, () => {
                while (true) {
                    uint maxdata;
                    Comedi.Range range;
                  int i = 0;
                    GLib.DateTime timestamp = new DateTime.now_local ();

                    foreach (var task in task_mmaps.keys) {
                        var device = task.device;
                        foreach (var channel in task.channels.values) {
                            (channel as Channel).timestamp = timestamp;
                            maxdata = (device as ComediDevice).dev.get_maxdata (
                                        (channel as Channel).subdevnum, (channel as Channel).num);

                            /* Analog Input */
                            if (channel is AIChannel) {

                                double meas = 0.0;
                                range = (device as ComediDevice).dev.get_range (
                                    (channel as Channel).subdevnum, (channel as Channel).num,
                                    (channel as AIChannel).range);

                                lock (data_register) {
                                    meas = Comedi.to_phys (data_register [i], range, maxdata);
                                }

                                (channel as AIChannel).add_raw_value (meas);
                                //stdout.printf ("%.1f ", meas);
                              i++;
                            }
                        }
                    }
                    //stdout.printf ("\n");

                    return true;
                }
            });
        }
    }
}
