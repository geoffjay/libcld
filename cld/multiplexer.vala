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

    /**
     * A list of channel references.
     */
    private Gee.List<string>? _taskrefs;
    public Gee.List<string>? taskrefs {
        get { return _taskrefs; }
        set { _taskrefs = value; }
    }

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

    /* The update interval, in milliseconds, of the channel raw value. */
    private int _interval_ms;
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

    construct {
        taskrefs = new Gee.ArrayList<string> ();
        task_mmaps = new Gee.TreeMap<Cld.ComediTask, void*> ();
    }

    /**
     * Construction using an xml node
     */
    public Cld.Multiplexer.from_xml_node (Xml.Node *node) {
        string value;

        if (node->type == Xml.ElementType.ELEMENT_NODE &&
            node->type != Xml.ElementType.COMMENT_NODE) {
            _id = node->get_prop ("id");
            /* iterate through node children */
            for (Xml.Node *iter = node->children; iter != null; iter = iter->next) {
                if (iter->name == "property") {
                    switch (iter->get_prop ("name")) {
                        case "fname":
                            fname = iter->get_content ();
                            break;
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
        }
    }

    public void generate () {
        int nchans = 0;
        var tasks = get_object_map (typeof (Cld.ComediTask));

        foreach (var task in tasks.values) {
            nchans+= (task as Cld.ComediTask).channels.size;
            var device = (task as Cld.ComediTask).device;
            var subdevice = (task as Cld.ComediTask).subdevice;
            var size = (device as Cld.ComediDevice).dev.get_buffer_size ((uint)subdevice);
            var fd = (device as Cld.ComediDevice).dev.fileno ();
            void *map;
            map = Posix.mmap (null, size, Posix.PROT_READ, Posix.MAP_SHARED, fd, 0);
            task_mmaps.set (task as Cld.ComediTask, map);
        }

        data_register = new ushort[nchans];
    }

    /* Set a value in the data register */
    public void set_raw (int index, ushort val) {
        lock (data_register) {
            data_register[index] = val;
        }
    }

    /* Get a value in the data register */
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
            /* Connect this signal to enable concurrent starting of streaming tasks */
            async_start.connect ((task as Cld.ComediTask).async_start);
            (task as Cld.ComediTask).run ();
        }

        /* async tasks require one extra step for a synchronized start. */
        var start = new GLib.DateTime.now_local ();
        async_start (start);

        open_fifo.begin ((obj, res) => {
            /* get a file descriptor */
            try {
                int fd = open_fifo.end (res);
                message ("Multiplexer with fifo %s and fd %d has a reader", fname, fd);

                bg_multiplex_data.begin (fd, (obj, res) => {
                    try {
                        bg_multiplex_data.end (res);
                        message ("Multiplexer with fifo %s multiplex data async ended", fname);
                    } catch (ThreadError e) {
                        string msg = e.message;
                        error (@"Thread error: $msg");
                    }
                });

            } catch (ThreadError e) {
                string msg = e.message;
                error (@"Thread error: $msg");
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
            message ("Acquisition controller is waiting for a reader to FIFO %s", fname);
            fd = Posix.open (fname, Posix.O_WRONLY);
            if (fd == -1) {
                message ("%s Posix.open error: %d: %s", fname, Posix.errno, Posix.strerror (Posix.errno));
            } else {
                message ("Acquisition controller opening FIFO %s fd: %d", fname, fd);
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
        int buffsz = 1048576;
        ushort word = 0;
        ushort[] b = new ushort[1];
        int total = 0;
        int i;
        bool channelize = false;
        int size;                    // the number of tasks in the multiplexer
        Cld.ComediDevice[] devices; // the Comedi devices used by these tasks
        Cld.ComediTask[] tasks;
        int[] nchans;               // the number of channels in each task
        int[] subdevices;           // the subdevice numbers for these devices
        int[] buffersizes;          // the data buffer sizes of each subdevice
        int[] buffer_contents;
        int[] nscans;               // the integral number of scans that are available in a data buffer
        int nscan = int.MAX;         // the integral number of scans that will be multiplexed
        ushort*[] maps;             // an array of pointers to memory mapped data for these subdevices
        int[] front;
        int[] back;
        Gee.Deque[] queues;

        size = task_mmaps.size;
        devices = new Cld.ComediDevice[size];
        tasks = new Cld.ComediTask[size];
        nchans = new int[size];
        subdevices = new int[size];
        buffersizes = new int[size];
        buffer_contents = new int[size];
        nscans = new int[size];
        maps = new void*[size];
        front = new int[size];
        back = new int[size];
        queues = new Gee.Deque<ushort>[size];

        i = 0;
        foreach (var task in task_mmaps.keys) {
            tasks[i] = task as ComediTask;
            devices[i] = (task as ComediTask).device as Cld.ComediDevice;
            nchans[i] = (task as ComediTask).channels.size;
            subdevices[i] = (task as ComediTask).subdevice;
            buffersizes[i] = (devices[i] as Cld.ComediDevice).dev.get_buffer_size (subdevices[i]);
            maps[i] = task_mmaps.get (task);
            front[i] = 0;
            back[i] = 0;
            queues[i] = (task as ComediTask).queue;
            i++;
        }

        GLib.Thread<int> thread = new GLib.Thread<int> ("%s_queue_data",  () => {
            while (true) {
/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>*/
//                for (i = 0; i < size; i++) {
//                    buffer_contents[i] = (devices[i] as Cld.ComediDevice).dev.get_buffer_contents (subdevices[i]);
//
//                    if (buffer_contents[i] >= (buffersizes[i] / 2)) {
//                        stdout.printf (">>>>>>>>>>>>>>>>>>> Buffer[%d] overflow: %d\n", i, buffer_contents[i]);
//                    }
//
//                    front[i] += buffer_contents[i];
//
//                    int col = 0;
//                    for (int j = back[i]; i < front[i]; i++) {
//                        col++;
//                        word = *(maps[i] + (j % (buffersizes[i] / 2)));
//                        //int x = queues[i].offer_head (word);
//                        stdout.printf ("%4X ", word);
//                        if (col == 48) {
//                            stdout.printf ("\n");
//                            col = 0;
//                        }
//                    }
//                    if (buffer_contents[i] > 0) {
//stdout.printf ("%d front - back: %d\n", i, front[i] - back[i]);
//                        int ret = (devices[i] as Cld.ComediDevice).dev.mark_buffer_read (
//                                                                subdevices[i], front[i] - back[i]);
//                        back[i] = front[i];
//                    }
//                }
/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>*/

/******************************************************************************************************/
                /* Determine the minimum integral size data required for multiplexing */
                nscan = int.MAX;
                for (i = 0; i < size; i++) {
                    nscans[i] = queues[i].size / nchans[i] ;
                    nscan = nscan < nscans[i] ? nscan : nscans[i];
                }

                /* scans */
                int counter = 0;
                for (i = 0; i < nscan; i++) {
                    channelize = ((total % 48000)== 0);
                    int raw_index = 0; // data register index for channels digital raw value.

                    /* tasks */
                    for (int j = 0; j < size; j++) {
                        /* channels */
                        for (int k = 0; k < nchans[j]; k++) {
                            if (j == 0) {
                                counter ++;
                            }
                            word = tasks[j].poll_queue ();
                            //if ((j == 0) && ((total % 48000) == 0)) {
                                //stdout.printf ("%12d %12d\n",
                                    //back[j] % (buffersizes[j] / 2),
                                    //(k + back[j] + i * nchans[j]) % (buffersizes[j] / 2));
                            //}

                            /* Write the data to the fifo */
                            b[0] = word;
                            Posix.write (fd, b, 2);

                            /* Write the raw value to a register */
                            //if (channelize) {
                            data_register[raw_index] = b[0];
                                if  ((j == 0) && (k == 0)) {
                                    message ("%4X", word);
                                }
                            //}

                            raw_index++;
                            total++;

                            if ((total % 32768) == 0) {
                                message ("%d: total written to multiplexer: %d            nscan: %d\n",
                                (int) Linux.gettid (), total, nscan);
                            }
                        }
                    }

                    if (channelize) {
                        do_channelizer ();
                    }

                    channelize = false;
                }

//                /* scans */
//                int counter = 0;
//                for (i = 0; i < nscan; i++) {
//                    channelize = ((total % 48000)== 0);
//                    int raw_index = 0; // data register index for channels digital raw value.
//
//                    /* tasks */
//                    for (int j = 0; j < size; j++) {
//                        /* channels */
//
//                        int offset2 = (devices[j] as Cld.ComediDevice).dev.get_buffer_offset (subdevices[j]);
//                        for (int k = 0; k < nchans[j]; k++) {
//                            if (j == 0) {
//                                counter ++;
//                            }
//                            //int offset = (k + i * nchans[j]) % (buffersizes[j] / 2);
//                            //int offset = k + back[j] + i * nchans[j];
//                            //word = *(maps[j] + offset);
//                            word = *(maps[j] + (back[j] + k) % (buffersizes[j] / 2));
////if ((j == 0) && ((total % 48000) == 0)) {
////stdout.printf ("%12d %12d\n",back[j] % (buffersizes[j] / 2), (k + back[j] + i * nchans[j]) % (buffersizes[j] / 2));
////}
//
//                            /* Write the data to the fifo */
//                            b[0] = word;
//                            Posix.write (fd, b, 2);
//
//                            /* Write the raw value to a register */
//                            //if (channelize) {
//                            data_register[raw_index] = b[0];
//                                if  ((j == 0) && (k == 0)) {
//                                    if (((k + offset2 / 2) % 2) != 0) {
//                                        stdout.printf ("%8d %12d\n", word,
//                                        (k + offset2 / 2));
//                                    }
////stdout.printf ("%4X %12llu %12llu\n", word, (k + back[j] + i * nchans[j]) % (buffersizes[j] / 2), back[j]);
//                                }
//                            //}
//
//                            raw_index++;
//                            total++;
////if ((total % 32768) == 0) {
////stdout.printf ("%d: total written to multiplexer: %d            nscan: %d\n",
////(int) Linux.gettid (), total, nscan);
////}
//                        }
//                        (devices[j] as Cld.ComediDevice).dev.mark_buffer_read (subdevices[j], 2 * nchans[j]);
//                        back[j] = (devices[j] as Cld.ComediDevice).dev.get_buffer_offset (subdevices[j]) / 2;
//                    }
//                    if (channelize) {
//                        do_channelizer ();
//                    }
//                    channelize = false;
//                }

                /* mark buffers as read */
//                if ((nscan) > 0) {
//                    for (i = 0; i < size; i++) {
//
//                        int off1 = (devices[i] as Cld.ComediDevice).dev.get_buffer_offset (subdevices[i]);
//                        int ret = (devices[i] as Cld.ComediDevice).dev.mark_buffer_read (
//                                                                    subdevices[i], nscan * nchans[i]);
//                        int off2 = (devices[i] as Cld.ComediDevice).dev.get_buffer_offset (subdevices[i]);
//                        if  (ret != (nscan * nchans[i])) {
//                        //if  (ret > 4096) {
//
//                            error ("Comedi mark_buffer_read failed %12d %12d %12d %12d %12d",
//                                    ret,
//                                    nscan * nchans[i],
//                                    ret + nscan * nchans[i],
//                                    off2 - off1,
//                                    off1);
//                        }
//                        back[i] += nscan * nchans[i];
//if (i == 0) {
//stdout.printf ("counter: %12d %12d\n", counter, nscan * nchans[i]);
//}
//                    }
//                }
/******************************************************************************************************/

                Thread.usleep (5000);
            }

            Idle.add ((owned) callback);
            return 0;
        });

        yield;
    }

    /**
     * Update the Cld.Channel values
     */
    public void do_channelizer () {

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

                    meas = Comedi.to_phys (data_register[i], range, maxdata);

                    (channel as AIChannel).add_raw_value (meas);
                    //stdout.printf ("%.1f ", meas);
                    i++;
                }
            }
        }
        //stdout.printf ("\n");
    }
}
