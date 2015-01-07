/**
 * libcld
 * Copyright (c) 2014, Geoff Johnson, All rights reserved.
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 3.0 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library.
 */

/**
 * Mutiplexes data from multiple tasks.
 */
public class Cld.Multiplexer : Cld.AbstractContainer {

    /* Property backing fields */
    private Gee.List<string>? _taskrefs;
    private string _fname;
    private int _interval_ms;

    /**
     * A list of channel references.
     */
    public Gee.List<string>? taskrefs {
        get { return _taskrefs; }
        set { _taskrefs = value; }
    }

    /* The name that identifies an interprocess communication pipe or socket. */
    public string fname {
        get { return _fname; }
        set { _fname = value; }
    }

    /* The update interval, in milliseconds, of the channel raw value. */
    public int interval_ms {
        get { return _interval_ms; }
        set { _interval_ms = value; }
    }

    /* A vector of the current binary data values of the channels */
    private ushort[] data_register;

    /**
     * A signal that starts streaming tasks concurrently.
     */
    public signal void async_start (GLib.DateTime start);

    private int fd = -1;

    /**
     * Common construction
     */
    construct {
        id = "mux0";
        fname = "/tmp/fifo-%s".printf (id);
        taskrefs = new Gee.ArrayList<string> ();
    }

    /**
     * Construction using an xml node
     */
    public Cld.Multiplexer.from_xml_node (Xml.Node *node) {
        id = node->get_prop ("id");

        /* Iterate through node children */
        for (Xml.Node *iter = node->children; iter != null; iter = iter->next) {
            if (iter->name == "property") {
                switch (iter->get_prop ("name")) {
                    case "interval-ms":
                        interval_ms = int.parse (iter->get_content ());
                        break;
                    case "taskref":
                        taskrefs.add (iter->get_content ());
                        break;
                    default:
                        break;
                }
            }
        }

        fname = "/tmp/fifo-%s".printf (id);
    }

    /**
     * Perform additional multiplexer initialization.
     */
    public void generate () {
        int n = 0;
        var tasks = get_object_map (typeof (Cld.ComediTask));

        foreach (var task in tasks.values) {
            n += (task as Cld.ComediTask).channels.size;
        }

        data_register = new ushort[n];
    }

    /**
     * Set a value in the data register.
     */
    public void set_raw (int index, ushort val) {
        lock (data_register) {
            data_register[index] = val;
        }
    }

    /**
     * Get a value in the data register.
     */
    public ushort get_raw (int index) {
        ushort val;

        lock (data_register) {
            val = data_register[index];
        }

        return val;
    }

    /**
     * Start the tasks and stream the data.
     */
    public async void run () {
        var tasks = get_object_map (typeof (Cld.ComediTask));
        var devices = get_object_map (typeof (Cld.ComediDevice));

        foreach (var task in tasks.values) {
            /* Uses a signal to enable concurrent start of streaming tasks */
            async_start.connect ((task as Cld.ComediTask).async_start);
            (task as Cld.ComediTask).run ();
        }

        /* Async tasks require one extra step for a synchronized start. */
        var start = new GLib.DateTime.now_local ();
        async_start (start);

        open_fifo.begin ((obj, res) => {
            /* Get a file descriptor */
            try {
                fd = open_fifo.end (res);
                debug ("Multiplexer with fifo `%s' and fd %d has a reader",
                       fname, fd);
            } catch (ThreadError e) {
                string msg = e.message;
                error (@"Thread error: $msg");
            }
        });

        bg_multiplex_data.begin ((obj, res) => {
            try {
                bg_multiplex_data.end (res);
                debug ("Multiplexer with fifo `%s' data async ended",
                        fname);
            } catch (ThreadError e) {
                string msg = e.message;
                error (@"Thread error: $msg");
            }
        });
    }

    /**
     * Opens a FIFO for inter-process communication.
     *
     * @param fname The path name of the named pipe
     * @return A file descriptor for the named pipe
     */
    private async int open_fifo () {
        SourceFunc callback = open_fifo.callback;
        GLib.Thread<int> thread = new GLib.Thread<int>.try ("open_fifo", () => {
            debug ("Multiplexer `%s' waiting for a reader to FIFO `%s'",
                   id, fname);
            fd = Posix.open (fname, Posix.O_WRONLY);
            if (fd == -1) {
                critical ("%s Posix.open error: %d: %s",
                          fname, Posix.errno, Posix.strerror (Posix.errno));
            } else {
                debug ("Acquisition controller opening FIFO `%s' fd: %d",
                       fname, fd);
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
    private async void bg_multiplex_data () throws ThreadError {
        SourceFunc callback = bg_multiplex_data.callback;
        int buffsz = 1048576;
        ushort word = 0;
        ushort[] b = new ushort[1];
        int total = 0;
        int i = 0;
        bool channelize = false;
        Cld.ComediDevice[] devices;     // the Comedi devices used by these tasks
        Cld.ComediTask[] tasks;
        int[] nchans;                   // the number of channels in each task
        int[] subdevices;               // the subdevice numbers for these devices
        int[] buffersizes;              // the data buffer sizes of each subdevice
        int[] buffer_contents;
        int[] nscans;                   // the integral number of scans that are available in a data buffer
        int nscan = int.MAX;            // the integral number of scans that will be multiplexed
        Gee.Deque[] queues;

        var _tasks = get_object_map (typeof (Cld.ComediTask));
        int size = _tasks.size;

        devices = new Cld.ComediDevice[size];
        tasks = new Cld.ComediTask[size];
        nchans = new int[size];
        subdevices = new int[size];
        buffersizes = new int[size];
        buffer_contents = new int[size];
        nscans = new int[size];
        queues = new Gee.Deque<ushort>[size];

        foreach (var task in _tasks.values) {
            tasks[i] = task as ComediTask;
            devices[i] = (task as ComediTask).device as Cld.ComediDevice;
            nchans[i] = (task as ComediTask).channels.size;
            subdevices[i] = (task as ComediTask).subdevice;
            buffersizes[i] = (devices[i] as Cld.ComediDevice).dev.get_buffer_size (subdevices[i]);
            queues[i] = (task as ComediTask).queue;
            i++;
        }

        GLib.Thread<int> thread = new GLib.Thread<int>.try ("%s_queue_data",  () => {
            while (true) {
                /* Determine the minimum integral size data required for multiplexing */
                nscan = int.MAX;
                for (i = 0; i < size; i++) {
                    nscans[i] = queues[i].size / nchans[i] ;
                    nscan = nscan < nscans[i] ? nscan : nscans[i];
                }

                /* scans */
                int counter = 0;
                for (i = 0; i < nscan; i++) {
                    /* FIXME: this is just for debugging purposes */
                    channelize = ((total % 48000) == 0);

                    int raw_index = 0;      // data register index for channels digital raw value.

                    /* tasks */
                    for (int j = 0; j < size; j++) {
                        /* channels */
                        for (int k = 0; k < nchans[j]; k++) {
                            if (j == 0) {
                                counter ++;
                            }
                            word = tasks[j].poll_queue ();

                            /* Write the data to the fifo */
                            b[0] = word;
                            if (fd != -1)
                                Posix.write (fd, b, 2);

                            /* Write the raw value to a register */
                            if (channelize) {
                                data_register[raw_index] = b[0];
                                if  ((j == 0) && (k == 0)) {
                                    debug ("%4X", word);
                                }
                            }

                            raw_index++;
                            total++;

                            if ((total % 32768) == 0) {
                                debug ("%d: total written to multiplexer: %12d nscan: %d\n",
                                (int) Linux.gettid (), total, nscan);
                            }
                        }
                    }

                    if (channelize) {
                        do_channelizer ();
                    }

                    channelize = false;
                }

                Thread.usleep (5000);
            }

            Idle.add ((owned) callback);
            return 0;
        });

        yield;
    }

    /**
     * Update the channel values
     */
    public void do_channelizer () {

        uint maxdata;
        Comedi.Range range;
        int i = 0;
        GLib.DateTime timestamp = new DateTime.now_local ();

        var tasks = get_object_map (typeof (Cld.ComediTask));

        foreach (var task in tasks.values) {
            var device = (task as Cld.ComediTask).device;
            foreach (var channel in (task as Cld.ComediTask).channels.values) {
                (channel as Cld.Channel).timestamp = timestamp;
                maxdata = (device as Cld.ComediDevice).dev.get_maxdata (
                            (channel as Cld.Channel).subdevnum,
                            (channel as Cld.Channel).num);

                /* Analog Input */
                if (channel is Cld.AIChannel) {
                    double meas = 0.0;
                    range = (device as Cld.ComediDevice).dev.get_range (
                                (channel as Cld.Channel).subdevnum,
                                (channel as Cld.Channel).num,
                                (channel as Cld.AIChannel).range);
                    meas = Comedi.to_phys (data_register[i++], range, maxdata);
                    (channel as Cld.AIChannel).add_raw_value (meas);
                    message ("%s: %f", channel.id, (channel as Cld.AIChannel).scaled_value);
                }
            }
        }
    }
}
