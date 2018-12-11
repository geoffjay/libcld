/**
 * libcld
 * Copyright (c) 2015, Geoff Johnson, All rights reserved.
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
 * A CSV style log file.
 */
public class Cld.CsvLog : Cld.AbstractLog {

    /**
     * Determines whether the file is renamed on open using the format string.
     */
    [Description(nick="Time Stamp", blurb="")]
    public Log.TimeStampFlag time_stamp { get; set; }

    private FileStream file_stream;

    /**
     * A file descriptor for the FIFO
     */
    private int fd = -1;

    /* Signal emits when a new row of data is available */
    private signal void new_row_available ();

    private ulong new_row_available_handler;
    private Gee.Map<Cld.Channel, ulong>? new_value_handlers;

    /* constructor */
    construct {
        new_value_handlers = new Gee.TreeMap<Cld.Channel, ulong> ();
    }

    public CsvLog () {
        id = "log0";
        name = "Log File";
        path = "/tmp/";
        file = "log.csv";
        rate = 10.0;          /* Hz */
        active = false;
        is_open = false;
        debug (status ());
        time_stamp = TimeStampFlag.OPEN;
        connect_signals ();
    }

    public CsvLog.from_xml_node (Xml.Node *node) {
        string value;
        this.node = node;

        active = false;
        is_open = false;
        debug (status ());

        if (node->type == Xml.ElementType.ELEMENT_NODE &&
            node->type != Xml.ElementType.COMMENT_NODE) {
            id = node->get_prop ("id");

            /* iterate through node children */
            for (Xml.Node *iter = node->children;
                 iter != null;
                 iter = iter->next) {
                if (iter->name == "property") {
                    switch (iter->get_prop ("name")) {
                        case "title":
                            name = iter->get_content ();
                            break;
                        case "path":
                            path = iter->get_content ();
                            break;
                        case "file":
                            file = iter->get_content ();
                            break;
                        case "rate":
                            value = iter->get_content ();
                            rate = double.parse (value);
                            break;
                        case "format":
                            date_format = iter->get_content ();
                            break;
                        case "time-stamp":
                            value = iter->get_content ();
                            time_stamp = TimeStampFlag.parse (value);
                            break;
                        case "data-source":
                            data_source = iter->get_content ();
                            break;
                        default:
                            break;
                    }
                } else if (iter->name == "object") {
                    if (iter->get_prop ("type") == "column") {
                        var column = new Column.from_xml_node (iter);
                        add (column);
                    }
                }
            }
        }

        if (!path.has_suffix ("/")) {
            path = "%s%s".printf (path, "/");
        }
        gfile = GLib.File.new_for_path (path + file);

        connect_signals ();
    }

    public override string status () {
        return "active: %s is_open: %s file: %s".printf (active.to_string (),
                                                                is_open.to_string (),
                                                                file);
    }

    /* Connect the notify signals */
    private void connect_signals () {
        Type type = get_type ();
        ObjectClass ocl = (ObjectClass)type.class_ref ();

        foreach (ParamSpec spec in ocl.list_properties ()) {
            notify[spec.get_name ()].connect ((s, p) => {
            update_node ();
            });
        }

        notify["gfile"].connect ((s,p) => {
            debug ("gfile will change from path: %s file: %s", path, file);
            path = gfile.get_parent ().get_path ();
            if (!path.has_suffix ("/")) {
                path = "%s%s".printf (path, "/");
            }

            file = gfile.get_basename ();
            debug ("gfile changed path: %s file: %s", path, file);
            debug (status ());
        });
    }

    private void update_node () {
        if (node != null) {
            if (node->type == Xml.ElementType.ELEMENT_NODE &&
                node->type != Xml.ElementType.COMMENT_NODE) {
                /* iterate through node children */
                for (Xml.Node *iter = node->children;
                     iter != null;
                     iter = iter->next) {
                    if (iter->name == "property") {
                        switch (iter->get_prop ("name")) {
                            case "title":
                                iter->set_content (name);
                                break;
                            case "path":
                                iter->set_content (path);
                                break;
                            case "file":
                                iter->set_content (file);
                                break;
                            case "rate":
                                iter->set_content (rate.to_string ());
                                break;
                            case "format":
                                iter->set_content (date_format);
                                break;
                            case "time-stamp":
                                iter->set_content (time_stamp.to_string ());
                                break;
                            default:
                                break;
                        }
                    }
                }
            }
        }
    }

    ~CsvLog () {
        if (get_objects() != null)
            get_objects().clear ();
    }

    /**
     * Print a string to the log file.
     *
     * @param toprint The string to print
     */
    public void file_print (string toprint) {
        if (is_open) {
            lock (file_stream) {
                file_stream.printf ("%s", toprint);
                file_stream.flush ();
            }
        }
    }

    /**
     * Open the file for logging.
     *
     * @return On successful open true, false otherwise.
     */
    public bool file_open () {
        string filename;
        string temp;
        string tempname;
        string tempext;

        /* if it was requested rename the file on open */
        if (time_stamp == TimeStampFlag.OPEN || time_stamp == TimeStampFlag.BOTH) {
            disassemble_filename (file, out tempname, out tempext);
            temp = "%s-%s.%s".printf (tempname, start_time.format (date_format), tempext);
        } else {
            temp = file;
        }

        if (path.has_suffix ("/"))
            filename = "%s%s".printf (path, temp);
        else
            filename = "%s/%s".printf (path, temp);

        /* Create the file if it doesn't exist already */
        if (!(Posix.access (filename, Posix.F_OK) == 0)) {
            FileStream.open (filename, "a+");
        }

        if (!(Posix.access (filename, Posix.W_OK) == 0) &&
           !(Posix.access (filename, Posix.R_OK) == 0)) {
            throw new Cld.FileError.ACCESS (
                    "Can't open log file %s", filename
                );
            is_open = false;
            debug (status ());

            return is_open;
        } else {
            /* open the file */
            debug ("Opening file: %s", filename);
            file_stream = FileStream.open (filename, "w+");

            if (file_stream == null) {
                is_open = false;
                debug (status ());

            } else {
                is_open = true;
                debug (status ());
                /* add the header */
                file_stream.printf ("# Log file: %s created at %s\n",
                                    name, start_time.format ("%F %T"));
            }
        }

        return is_open;
    }

    /**
     * Close the file.
     */
    public void file_close () {
        DateTime time = new DateTime.now_local ();

        if (is_open) {
            /* add the footer */
            file_stream.printf ("\n# Log file: %s closed at %s",
                                name, time.format ("%F %T"));
            /* setting a GLib.FileStream object to null apparently forces a
             * call to stdlib's close () */
            file_stream = null;
            is_open = false;
            debug (status ());
        }
    }

    /**
     * Renames the file using the format string.
     *
     * @param reopen Whether or not to reopen a new file using the base name.
     */
    public void file_mv_and_date (bool reopen) {
        string src;
        string dest;
        string dest_name;
        string dest_ext;
        DateTime time = new DateTime.now_local ();

        /* XXX give log class a format string to use for tagging file names */

        /* call to close writes the footer and sets the stream to null */
        file_close ();

        /* generate new file name to move to based on date and
           existing name */
        disassemble_filename (file, out dest_name, out dest_ext);
        if (time_stamp == TimeStampFlag.OPEN || time_stamp == TimeStampFlag.BOTH) {
            src = "%s-%s.%s".printf (dest_name, start_time.format (date_format), dest_ext);
        } else {
            src = file;
        }

        if (!path.has_suffix ("/"))
            path = path + "/";

        src = "%s/%s".printf (path, src);

        if (time_stamp == TimeStampFlag.OPEN)
            dest = src;
        else
            dest = "%s%s-%s.%s".printf (path, dest_name, time.format (date_format), dest_ext);

        /* rename the file */
        if (FileUtils.rename (src, dest) < 0)
            stderr.printf ("An error occurred while renaming " +
                           "the file: %s%s", path, file);

        /* and recreate the original file if requested */
        if (reopen)
            file_open ();
    }

    /**
     * Writes a standard header to the top of the file.
     */
    public void write_header () {
        string tags = "Time";
        string cals = "# Channel Calibrations:\n#\n";

        foreach (var object in get_objects().values) {
            debug ("Found object [%s]", object.id);
            if (object is Column) {
                var channel = ((object as Column).channel as Channel);
                Type type = (channel as GLib.Object).get_type ();
                debug ("Received object is Column - %s", type.name ());

                if (channel is ScalableChannel) {
                    var calibration = (channel as ScalableChannel).calibration;
                    cals += "# %s\n".printf (channel.uri);
                    cals += "#   calibration: y =";

                    foreach (var coefficient in (calibration as Container).get_objects().values) {
                        cals += "%.3f * x^%d + ".printf (
                                (coefficient as Coefficient).value,
                                (coefficient as Coefficient).n
                            );
                    }

                    cals = cals.substring (0, cals.length - 3);
                    cals += "\n#   tag: %s".printf (channel.tag);
                    cals += "\n#   units: %s".printf (calibration.units);
                    cals += "\n#   description: %s\n#\n".printf (channel.desc);
                    tags += "\t%s".printf (channel.tag);
                } else if (channel is DChannel) {
                    tags += "\t%s".printf (channel.tag);
                }
            }
        }

        var header = "#\n%s# Logging rate: %.2f Hz\n\n#%s\n".printf (cals, rate, tags);

        file_print (header);
    }

    /**
     * Write the next line in the file.
     */
    public override void log_entry_write (Cld.LogEntry entry) {
        string line = "";
        char sep = '\t';

        line = "%lld\t".printf (entry.time_us);

        int i = 0;
        foreach (var object in get_objects().values) {
            if (object is Cld.Column) {
                //var datum = entry.data.get ((object as Cld.Column).chref);
                var datum = entry.data [i];
                line += "%.6f%c".printf (datum, sep);
                i++;
            }
        }

        line = line.substring (0, line.length - 1);
        line += "\n";
        file_print (line);
    }

    /**
     * {@inheritDoc}
     */
    public override void start () {
        start_time = new DateTime.now_local ();
        int64 time64 = 0;
        int datachans = 0;
        int rowcnt = 0;
        ulong handler;
        file_open ();
        write_header ();

        /* Count the number of channels */
        var columns = get_children (typeof (Cld.Column));

        nchans = columns.size;
        active = true;
        debug (status ());
        if (data_source == "channel" || data_source == null) {
            /* Background channel watch fills the entry queue */
            bg_channel_watch.begin (() => {
                try {
                    debug ("Channel watch async ended");
                } catch (ThreadError e) {
                    string msg = e.message;
                    error (@"Thread error: $msg");
                }
            });
        } else {

            /* XXX FIXME Not using FIFOs for IPC here. Will us 0MQ socket later */
            /* Open the FIFO data buffers. */
/*
 *            foreach (string fname in fifos.keys) {
 *                if (Posix.access (fname, Posix.F_OK) == -1) {
 *                    int res = Posix.mkfifo (fname, 0777);
 *                    if (res != 0) {
 *                        error ("Context could not create fifo %s\n", fname);
 *                    }
 *                }
 *                open_fifo.begin (fname, (obj, res) => {
 *                    try {
 *                        fd = open_fifo.end (res);
 *                        message ("Got a writer for %s", fname);
 *
 *                        [> Background fifo watch queues fills the entry queue <]
 *                        bg_fifo_watch.begin (fd, (obj, res) => {
 *                            try {
 *                                bg_fifo_watch.end (res);
 *                                message ("Log fifo watch async ended");
 *                            } catch (ThreadError e) {
 *                                string msg = e.message;
 *                                error (@"Thread error: $msg");
 *                            }
 *                        });
 *
 *                        bg_raw_process.begin ((obj, res) => {
 *                            try {
 *                                bg_raw_process.end (res);
 *                                message ("Raw data queue processing async ended");
 *                            } catch (ThreadError e) {
 *                                string msg = e.message;
 *                                error (@"Thread error: $msg");
 *                            }
 *                        });
 *                    } catch (ThreadError e) {
 *                        string msg = e.message;
 *                        error (@"Thread error: $msg");
 *                    }
 *                });
 *            }
 */
            /**
             * Write data to the log entry queue each time a new row of data
             * is available (when all of the values have new data).
             **/

             /* Count the primary data channels (ie. excluding math channels) */
            foreach (var column in get_objects().values) {
                if (column is Cld.Column) {
                    var channel = (column as Cld.Column).channel;

#if USE_MATHEVAL
                    if (channel is Cld.MathChannel) {
                        continue;
                    }
#endif

                    datachans++;
                    /* Increment row counter when a new value occurs */
                    if (channel is Cld.ScalableChannel) {
                        handler = (channel as Cld.ScalableChannel).
                                            new_value.connect ((id, value) => {
                            rowcnt++;
                            if (rowcnt == datachans) {
                                new_row_available ();
                                rowcnt = 0;
                            }
                        });
                        new_value_handlers.set (channel as ScalableChannel, handler);

                    } else if (channel is Cld.DChannel) {
                        handler = (channel as Cld.DChannel).
                                            new_value.connect ((id, value) => {
                            rowcnt++;
                            if (rowcnt == datachans) {
                                new_row_available ();
                                rowcnt = 0;
                            }
                        });
                        new_value_handlers.set (channel as Cld.DChannel, handler);
                    }
                }
            }

            new_row_available_handler = new_row_available.connect (() => {
                Cld.LogEntry entry = new Cld.LogEntry ();
                entry.data = new double [nchans];
                /**
                 * The timestamp is artificially generated from
                 * the rate parameter which is assumed to be
                 * correct.
                 */
                entry.timestamp = start_time.add_seconds (1 / rate);//creates an incremented copy
                time64 += (int64)(1e6 / rate);
                entry.time_us = time64;

                int i = 0;

                foreach (var column in get_objects().values) {
                    if (column is Cld.Column) {
                        entry.data [i++] = (column as Cld.Column).channel_value;
                    }
                }

                offer_entry (entry); //Work around because entry_queue is not lockable from here
                /*
                 *lock (entry_queue) {
                 *    entry_queue.offer_head (entry);
                 *}
                 */
            });
        }

        bg_entry_write.begin (() => {
            try {
                message ("Log entry queue write async ended");
            } catch (ThreadError e) {
                string msg = e.message;
                error (@"Thread error: $msg");
            }
        });
    }

    private async int open_fifo (string fname) {
        SourceFunc callback = open_fifo.callback;

        GLib.Thread<int> thread = new GLib.Thread<int>.try ("open_fifo_%s".printf (fname), () => {
            message ("%s is is waiting for a writer to FIFO %s",this.id, fname);
            if (fd == -1)
                fd = Posix.open (fname, Posix.O_RDONLY);
            fifos.set (fname, fd);
            if (fd == -1) {
                message ("%s Posix.open error: %d: %s",id, Posix.errno, Posix.strerror (Posix.errno));
            } else {
                message ("CSV log is opening FIFO %s fd: %d", fname, fd);
            }

            Idle.add ((owned) callback);

            return 0;
        });
        yield;

        return fd;
    }

    /**
     * {@inheritDoc}
     */
    public override void process_entry_queue () {
        for (int i = 0; i < entry_queue.size; i++) {
            log_entry_write (entry_queue.poll_tail ());
        }
    }

    /**
     * {@inheritDoc}
     */
    public override void stop () {
        disconnect (new_row_available_handler);
        foreach (var entry in new_value_handlers.entries) {
            var handler = entry.value;
            var channel = entry.key;
            if (channel is Cld.ScalableChannel) {
                (channel as Cld.ScalableChannel).disconnect (handler);
            } else if (channel is Cld.DChannel) {
                (channel as Cld.DChannel).disconnect (handler);
            }
        }

        if (active) {
            /* Wait for the queue to be empty */
            GLib.Timeout.add (100, deactivate_cb);
        }
        file_close ();
    }

    private bool deactivate_cb () {
        if (entry_queue.size == 0) {
            active = false;
            debug (status ());

            return false;
        } else {

            return true;
        }
    }

    /**
     * these methods directly pilfered from shotwell's util.vala file
     */

    private long find_last_offset (string str, char c) {
        long offset = str.length;
        while (--offset >= 0) {
            if (str[offset] == c)
                return offset;
        }
        return -1;
    }

    private void disassemble_filename (string basename,
                                       out string name,
                                       out string ext) {
        long offset = find_last_offset (basename, '.');
        if (offset <= 0) {
            name = basename;
            ext = null;
        } else {
            name = basename.substring (0, offset);
            ext = basename.substring (offset + 1, -1);
        }
    }

    public uchar[] string_to_uchar_array (string str) {
        uchar[] data = new uchar[0];
        for (int ctr = 0; ctr < str.length; ctr++)
            data += (uchar) str[ctr];
        return data;
    }
}
