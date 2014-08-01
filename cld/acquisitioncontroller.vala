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
 */
using Comedi;

public class Cld.AcquisitionController : Cld.AbstractController {

    /**
     * A FIFO for holding data to be processed.
     */
    private Cld.CircularBuffer queue;
    private int qsize = 262144;

    /* Buffer size for reading from the named pipe FIFO */
    private int bufsz = 4096;

    /**
     * Default construction
     */
    construct {
        _objects = new Gee.TreeMap<string, Cld.Object> ();
        queue = new Cld.CircularBuffer.from_size (qsize);
        queue.upper = qsize / 2;
        queue.high_level.connect (high_queue_cb);
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
        /* Open the FIFO data buffers. */
        foreach (string fname in fifos.keys) {
//            if (Posix.access (fname, Posix.F_OK) == -1) {
//                int res = Posix.mkfifo (fname, 0777);
//                if (res != 0) {
//                    Cld.error ("%s could not create fifo %s\n",id, fname);
//                }
//            }
            open_fifo.begin (fname, () => {
                Cld.debug ("got a writer for %s", fname);
            });
        }

        bg_fifo_watch.begin ((obj, res) => {
            try {
                bg_fifo_watch.end (res);
                Cld.debug ("Acquisiton controller %s fifo watch async ended", id);
            } catch (ThreadError e) {
                string msg = e.message;
                Cld.error (@"Thread error: $msg");
            }
        });

//        bg_process_data.begin ((obj, res) => {
//            try {
//                bg_process_data.end (res);
//                Cld.debug ("Queue data processing async ended");
//            } catch (ThreadError e) {
//                string msg = e.message;
//                Cld.error (@"Thread error: $msg");
//            }
//        });
    }

    private async void open_fifo (string fname) {
        SourceFunc callback = open_fifo.callback;
        GLib.Thread<int> thread = new GLib.Thread<int> ("open_fifo_%s".printf (fname), () => {
            Cld.debug ("%s is is waiting for a writer to FIFO %s",this.id, fname);
            int fd = Posix.open (fname, Posix.O_RDONLY);
            fifos.set (fname, fd);
            if (fd == -1) {
                Cld.debug ("%s Posix.open error: %d: %s",id, Posix.errno, Posix.strerror (Posix.errno));
            } else {
                Cld.debug ("Opening FIFO %s fd: %d", fname, fd);
                Idle.add ((owned) callback);
            }

            return 0;
        });

        yield;
    }

    /**
     * Launches a thread that pulls data from the data FIFO and pushes
     * it to a queue.
     */
    private async void bg_fifo_watch () throws ThreadError {
        SourceFunc callback = bg_fifo_watch.callback;

        GLib.Thread<int> thread = new GLib.Thread<int> ("bg_fifo_watch",  () => {
            ushort [] buf = new ushort [bufsz];
            int num = 0;
            int total = 0;

            while (true) {
                foreach (int fd in fifos.values) {
                    if (fd > 0) {
                        Posix.fd_set rdset;

                        Posix.timeval timeout = Posix.timeval ();
                        Posix.FD_ZERO (out rdset);
                        Posix.FD_SET (fd, ref rdset);
                        timeout.tv_sec = 0;
                        timeout.tv_usec = 50000;
                        num = Posix.select (fd + 1, &rdset, null, null, timeout);

                        if (num < 0) {
                            if (Posix.errno == Posix.EAGAIN) {
                                perror("read");
                            }
                        } else if (num == 0) {
                            stdout.printf ("hit timeout\n");
                        } else if ((Posix.FD_ISSET (fd, rdset)) == 1) {
                            if ((num = (int)Posix.read (fd, buf, bufsz)) == -1) {
                                Cld.debug("read error");
                            } else {
                                lock (queue) {
                                    for (int i = 0; i < num / 2; i++) {
                                        queue.write (buf [i]);
                                    }
                                    total += num;
//stdout.printf ("\nread %d total %d start: %d end: %d in_use: %d\n", num, total, queue.start, queue.end, queue.in_use ());
                                }
                            }
                        }
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
     * Pull a block of data from the queue and processes it.
     */
//    private async void bg_process_data () throws ThreadError {
//        SourceFunc callback = bg_process_data.callback;
//        ushort val = 0;
//
//        GLib.Thread<int> thread = new GLib.Thread<int> ("bg_process_data", () => {
//            int count = 0;
//            while (true) {
//                lock (queue) {
//                    while (!queue.is_empty ()) {
////stdout.printf ("before processed: %d start: %d end %d in use %d\n", count, queue.start, queue.end, queue.in_use ());
//                        for (int i = 0; i < queue.in_use (); i++) {
//                            val = queue.read ();
//                            count++;
//                            stdout.printf ("%u ", val);
//                            if ((count % 16) == 0 ) {
//                                count = 0;
//                                stdout.printf ("\n");
//                            }
//                        }
////stdout.printf ("\nafter processed: %d start: %d end %d\n", count, queue.start, queue.end);
//                    }
//                }
//                Thread.usleep (10000);
//            }
//
//            Idle.add ((owned) callback);
//            return 0;
//        });
//        //thread.set_priority (ThreadPriority.LOW);
//
//        yield;
//    }
    private void high_queue_cb () {
        ushort val = 0;
        int count = 0;

        lock (queue) {
            while (!queue.is_empty ()) {
//stdout.printf ("before processed: %d start: %d end %d in use %d\n", count, queue.start, queue.end, queue.in_use ());
                for (int i = 0; i < queue.in_use () - 1; i++) {
                    val = queue.read ();
                    count++;
                    stdout.printf ("%u ", val);
                    if ((count % 16) == 0 ) {
                        count = 0;
                        stdout.printf ("\n");
                    }
                }
//stdout.printf ("\nafter processed: %d start: %d end %d\n", count, queue.start, queue.end);
            }
        }
    }



    /**
     * {@inheritDoc}
     */
    public override void generate () {
    }
}
