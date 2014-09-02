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
    private Gee.Map<string, Gee.LinkedList<Cld.ComediTask>> multiplexers;

    /**
     * The tasks that are contained in this.
     */
    private Gee.Map<string, Cld.Object> tasks;

    /**
     * A signal that starts streaming tasks concurrently.
     */
    public signal void async_start ();

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
    }

    public async void stream_data (string fname) {
        open_fifo.begin (fname, (obj, res) => {
            /* get a file descriptor */
            try {
                int fd = open_fifo.end (res);
                Cld.debug ("Acquisition controller %s with fifo %s and fd %d has a reader", id, fname, fd);

                /* Start writing to the file descriptor */
                bg_fifo_write.begin (fname, fd, (obj, res) => {
                    try {
                        bg_fifo_write.end (res);
                        Cld.debug ("Acquisition controller %s fifo write async ended", id);
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

    private async int open_fifo (string fname) {
        SourceFunc callback = open_fifo.callback;
        int fd = -1;
        GLib.Thread<int> thread = new GLib.Thread<int> ("open_fifo", () => {
            Cld.debug ("Acquisition controller is waiting for a reader to FIFO %s", fname);
            fd = Posix.open (fname, Posix.O_WRONLY);
            if (fd == -1) {
                Cld.debug ("%s Posix.open error: %d: %s",id, Posix.errno, Posix.strerror (Posix.errno));
            } else {
                Cld.debug ("Acquisition controller opening FIFO %s fd: %d", fname, fd);
            }

            Idle.add ((owned) callback);
            return  0;
        });

        yield;

        return fd;
    }


    private async void bg_fifo_write (string fname, int fd) throws ThreadError {
        SourceFunc callback = bg_fifo_write.callback;
        ushort[] b = new ushort[1];
        ushort word = 0;
        int total = 0;

        var tasks = multiplexers.get (fname);
        foreach (var task in tasks) {

            GLib.Thread<int> thread = new GLib.Thread<int> ("bg_fifo_write",  () => {

            while (true) {
                if ((task as ComediTask).queue.size > 0) {
                    for (int i = 0; i < (task as ComediTask).queue.size; i++) {
                        word = (task as Cld.ComediTask).poll_queue ();
                        total ++;
//if ((total % 32768) == 0)
//stdout.printf ("%d: total written to fifo %d\n",(int) Linux.gettid (), total * (int)sizeof (ushort));
                        b[0] = word;
                        Posix.write (fd, b, 2);
                    }
                    Thread.usleep (10000);
                }
            }

            Idle.add ((owned) callback);
            return 0;
            });

        }

        yield;
    }

//    /**
//     * Launches a thread that pulls data from the data FIFO and pushes
//     * it to a queue.
//     */
//    private async void bg_fifo_watch () throws ThreadError {
//        SourceFunc callback = bg_fifo_watch.callback;
//
//        GLib.Thread<int> thread = new GLib.Thread<int> ("bg_fifo_watch",  () => {
//            ushort [] buf = new ushort [bufsz];
//            int num = 0;
//            int total = 0;
//
//            while (true) {
//                foreach (int fd in fifos.values) {
//                    if (fd > 0) {
//                        Posix.fd_set rdset;
//
//                        Posix.timeval timeout = Posix.timeval ();
//                        Posix.FD_ZERO (out rdset);
//                        Posix.FD_SET (fd, ref rdset);
//                        timeout.tv_sec = 0;
//                        timeout.tv_usec = 50000;
//                        num = Posix.select (fd + 1, &rdset, null, null, timeout);
//
//                        if (num < 0) {
//                            if (Posix.errno == Posix.EAGAIN) {
//                                perror("read");
//                            }
//                        } else if (num == 0) {
//                            stdout.printf ("hit timeout\n");
//                        } else if ((Posix.FD_ISSET (fd, rdset)) == 1) {
//                            if ((num = (int)Posix.read (fd, buf, bufsz)) == -1) {
//                                Cld.debug("read error");
//                            } else {
//                                lock (queue) {
//                                    for (int i = 0; i < num / 2; i++) {
//                                        queue.write (buf [i]);
//                                        ////queue.offer_head (buf [i]);
//                                    }
//                                    total += num;
//stdout.printf ("\nread %d total %u start: %u end: %u in_use: %u\n", num, total, queue.start, queue.end, queue.in_use ());
//                                }
//                            }
//                        }
//                    }
//                }
//                Thread.usleep (10000);
//            }
//
//            Idle.add ((owned) callback);
//            return 0;
//        });
//
//        yield;
//    }
//
//    /**
//     * Pull a block of data from the queue and processes it.
//     */
//    private async void bg_process_data () throws ThreadError {
//        SourceFunc callback = bg_process_data.callback;
//        ushort val = 0;
//
//        GLib.Thread<int> thread = new GLib.Thread<int> ("bg_process_data", () => {
//            uint count = 0;
//
//            while (true) {
//                lock (queue) {
//                    while (queue.size != 0) {
//                        if (count < 4) {
//                        stdout.printf ("monotonic: %llX\n", GLib.get_monotonic_time ());
//                            for (int i = 0; i < 4; i++) {
//                                val = queue.read ();
//                                ////val = queue.poll_tail ();
//                                count++;
//                                stdout.printf ("%4X ", val);
//                            }
//                            stdout.printf ("\n");
//                        }
//
////stdout.printf ("before processed: %u start: %u end %u in use %u\n", count, queue.start, queue.end, queue.in_use ());
//                        for (int i = 0; i < queue.in_use (); i++) {
//                        ////for (int i = 0; i < queue.size; i++) {
//                            val = queue.read ();
//                            ////val = queue.poll_tail ();
//                            count++;
//                            //stdout.printf ("%u ", val);
//                            if (((count - 4) % 16) == 0 ) {
//                                //count = 0;
//                                //stdout.printf ("\n");
//                            }
//                        }
////stdout.printf ("\nafter processed: %u in use %u\n", count, queue.size);
//                    }
//                }
//                Thread.usleep (10000);
//            }
//
//            Idle.add ((owned) callback);
//            return 0;
//        });
//        thread.set_priority (ThreadPriority.LOW);
//
//        yield;
//    }

    /**
     * {@inheritDoc}
     */
    public override void generate () {
        tasks = get_object_map (typeof (Cld.ComediTask));
        generate_multiplexers ();
        foreach (var task in tasks.values) {
            /* Connect this signal to enable concurrent starting of streaming tasks */
            async_start.connect ((task as Cld.ComediTask).async_start);
        }
    }

    /**
     * Update task fifo lists in preparation for logging.
     * @param log A log that requires data to be logged.
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
     * Combine individual task buffers to form a data multiplexer.
     */
    private void generate_multiplexers () {
        multiplexers = new Gee.HashMap<string, Gee.LinkedList<Cld.ComediTask>> ();
        foreach (var task in tasks.values) {
            foreach (var fifo in ((task as Cld.ComediTask).fifos.keys)) {
                if (!(multiplexers.has_key (fifo))) {
                    var task_list = new Gee.LinkedList<Cld.ComediTask> ();
                    task_list.add (task as Cld.ComediTask);
                    multiplexers.set (fifo, task_list);
                } else {
                    var task_list = multiplexers.get (fifo);
                    if (!(task_list.contains (task as Cld.ComediTask))) {
                        task_list.add (task as Cld.ComediTask);
                    }
                    multiplexers.set (fifo, task_list);
                }
            }
        }
    }
}
