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
 * A CSV style log file.
 */
public class Cld.CsvLog : Cld.AbstractLog {

    /**
     * Property backing fields.
     */
    private Gee.Map<string, Object> _objects;

    /**
     * Determines whether the file is renamed on open using the format string.
     */
    public Log.TimeStampFlag time_stamp { get; set; }

    private FileStream file_stream;


    /* constructor */
    construct {
    }

    public CsvLog () {
        id = "log0";
        name = "Log File";
        path = "/tmp/";
        file = "log.csv";
        rate = 10.0;          /* Hz */
        active = false;
        is_open = false;
        time_stamp = TimeStampFlag.OPEN;
    }

    public CsvLog.from_xml_node (Xml.Node *node) {
        string value;

        active = false;
        is_open = false;

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
                        default:
                            break;
                    }
                } else if (iter->name == "object") {
                    if (iter->get_prop ("type") == "column") {
                        var column = new Column.from_xml_node (iter);
                        column.parent = this;
                        add (column);
                    }
                }
            }
        }
    }

    ~CsvLog () {
        if (_objects != null)
            _objects.clear ();
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

        /* original implementation checked for the existence of requested
         * file and posted error message if it is, reimplement that later */
        if (path.has_suffix ("/"))
            filename = "%s%s".printf (path, temp);
        else
            filename = "%s/%s".printf (path, temp);

        /* open the file */
        message ("Opening file: %s", filename);
        file_stream = FileStream.open (filename, "w+");

        if (file_stream == null) {
            is_open = false;
        } else {
            is_open = true;
            /* add the header */
            file_stream.printf ("Log file: %s created at %s\n\n",
                                name, start_time.format ("%F %T"));
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
            file_stream.printf ("\nLog file: %s closed at %s",
                                name, time.format ("%F %T"));
            /* setting a GLib.FileStream object to null apparently forces a
             * call to stdlib's close () */
            file_stream = null;
            is_open = false;
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
        dest = "%s%s-%s.%s".printf (path, dest_name, time.format (date_format), dest_ext);

        if (path.has_suffix ("/"))
            src = "%s%s".printf (path, src);
        else
            src = "%s/%s".printf (path, src);

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
        //string units = "[HH:MM:SS.mmm]";
        string units = "[us]";
        string cals = "Channel Calibrations:\n\n";

        foreach (var object in objects.values) {
            message ("Found object [%s]", object.id);
            if (object is Column) {
                var channel = ((object as Column).channel as Channel);
                Type type = (channel as GLib.Object).get_type ();
                message ("Received object is Column - %s", type.name ());

                if (channel is ScalableChannel) {
                    var calibration = (channel as ScalableChannel).calibration;
                    cals += "%s:\ty = ".printf (channel.uri);

                    foreach (var coefficient in (calibration as Container).objects.values) {
                        cals += "%.3f * x^%d + ".printf (
                                (coefficient as Coefficient).value,
                                (coefficient as Coefficient).n
                            );
                    }

                    cals = cals.substring (0, cals.length - 3);
                    cals += "\t(%s)\n".printf (channel.desc);
                    units += "\t[%s]".printf (calibration.units);
                    tags += "\t%s".printf (channel.tag);
                } else if (channel is DChannel) {
                    tags += "\t%s".printf (channel.tag);
                }
            }
        }

        var header = "%s\nLogging rate: %.2f Hz\n\n%s\n%s\n".printf (cals, rate, tags, units);

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
        foreach (var object in objects.values) {
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
        file_open ();
        write_header ();

        /* Count the number of channels */
        var columns = get_children (typeof (Cld.Column));
        nchans = columns.size;

        active = true;
        if (fifos.size != 0) {
            /* Open the FIFO data buffers. */
            foreach (string fname in fifos.keys) {
                open_fifo.begin (fname, (obj, res) => {
                    try {
                        int fd = open_fifo.end (res);
                        message ("got a writer for %s", fname);

                        /* Background fifo watch queues fills the entry queue */
                        bg_fifo_watch.begin (fd, (obj, res) => {
                            try {
                                bg_fifo_watch.end (res);
                                message ("Log fifo watch async ended");
                            } catch (ThreadError e) {
                                string msg = e.message;
                                error (@"Thread error: $msg");
                            }
                        });

                        bg_raw_process.begin ((obj, res) => {
                            try {
                                bg_raw_process.end (res);
                                message ("Raw data queue processing async ended");
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
        } else {
            /* Background channel watch fills the entry queue */
            bg_channel_watch.begin (() => {
                try {
                    message ("Channel watch async ended");
                } catch (ThreadError e) {
                    string msg = e.message;
                    error (@"Thread error: $msg");
                }
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
        int fd = -1;

        GLib.Thread<int> thread = new GLib.Thread<int> ("open_fifo_%s".printf (fname), () => {
            message ("%s is is waiting for a writer to FIFO %s",this.id, fname);
            fd = Posix.open (fname, Posix.O_RDONLY);
            fifos.set (fname, fd);
            if (fd == -1) {
                message ("%s Posix.open error: %d: %s",id, Posix.errno, Posix.strerror (Posix.errno));
            } else {
                message ("Sqlite log is opening FIFO %s fd: %d", fname, fd);
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
        while (entry_queue.size > 0) {
            log_entry_write (entry_queue.poll_tail ());
        }
    }

    /**
     * {@inheritDoc}
     */
    public override void stop () {
        if (active) {
            active = false;
        }
        file_close ();
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
