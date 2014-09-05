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
    }

    /**
     * Opens a named pipe FIFO and starts the data writing thread.
     * @param fname The path name of the named pipe.
     */
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

    /**
     * Opens a FIFO for inter-process communication.
     * @param fname The path name of the named pipe.
     * @return A file descriptor for the named pipe.
     */
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

    /**
     * Writes data to a FIFO for inter-process communication.
     * @param fname The path name of the named pipe.
     * @param fd A file descriptor for the named pipe.
     */
    private async void bg_fifo_write (string fname, int fd) throws ThreadError {
        SourceFunc callback = bg_fifo_write.callback;
        ushort[] b = new ushort[1];
        ushort word = 0;
        int total = 0;

        var tasks = multiplexers.get (fname);

            GLib.Thread<int> thread = new GLib.Thread<int> ("%s_fifo_write".printf (uri),  () => {

            while (true) {
                foreach (Cld.ComediTask task in tasks) {
                    if (task.queue.size > 0) {
                        for (int i = 0; i < (task as ComediTask).queue.size; i++) {
                            word = (task as Cld.ComediTask).poll_queue ();
                            total ++;
if ((total % 32768) == 0) {
    stdout.printf ("%d: total written to %s %d    QUEUE: %d\n",
    (int) Linux.gettid (), fname, total * (int)sizeof (ushort), (task as ComediTask).queue.size);
}
                            b[0] = word;
                            Posix.write (fd, b, 2);
                        }
                    }
                    Thread.usleep (10000);
                }
            }

            Idle.add ((owned) callback);
            return 0;
            });

        yield;
    }

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
