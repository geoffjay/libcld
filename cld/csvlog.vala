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

/**
 * A CSV style log file.
 */
public class Cld.CsvLog : AbstractContainer {

    /**
     * Property backing fields.
     */
    private Gee.Map<string, Object> _objects;

    /**
     * {@inheritDoc}
     */
    public override string id { get; set; }

    /**
     * {@inheritDoc}
     */
    public override string name { get; set; }

    /**
     * {@inheritDoc}
     */
    public override string path { get; set; }

    /**
     * {@inheritDoc}
     */
    public override string file { get; set; }

    /**
     * {@inheritDoc}
     */
    public override double rate { get; set; }

    /**
     * {@inheritDoc}
     */
    public override int dt { get { return (int)(1e3 / rate); } }

    /**
     * {@inheritDoc}
     */
    public override bool active { get; set; default = false; }

    /**
     * {@inheritDoc}
     */
    public override bool is_open { get; set; }

    /**
     * {@inheritDoc}
     */
    public override string date_format { get; set; }

    /**
     * Determines whether the file is renamed on open using the format string.
     */
    public Log.TimeStampFlag time_stamp { get; set; }

    /**
     * {@inheritDoc}
     */
    public override Gee.Map<string, Object> objects {
        get { return (_objects); }
        set { update_objects (value); }
    }

    /**
     * File stream to use as output.
     */
    private FileStream file_stream;

    /**
     * DateTime data to use for time stamping log entries.
     */
    private DateTime start_time;

    /* constructor */
    public CsvLog () {
        id = "log0";
        name = "Log File";
        path = "/tmp/";
        file = "log.csv";
        rate = 10.0;          /* Hz */
        active = false;
        is_open = false;
        time_stamp = TimeStampFlag.OPEN;

        objects = new Gee.TreeMap<string, Object> ();
    }

    public CsvLog.from_xml_node (Xml.Node *node) {
        string value;

        objects = new Gee.TreeMap<string, Object> ();

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
                        objects.set (column.id, column);
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
     * Connect the columns to their corresponding channel signals.
     */
    public void connect_signals () {
        foreach (var column in objects.values) {
            if (column is Cld.Column) {
                var channel = (column as Cld.Column).channel;
                (channel as Cld.ScalableChannel).new_value.connect ((id, value) => {
                    (column as Cld.Column).channel_value = value;
                });
            }
        }
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

        start_time = new DateTime.now_local ();

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
        GLib.message (filename);
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
            Cld.debug ("Found object [%s]", object.id);
            if (object is Column) {
                var channel = ((object as Column).channel as Channel);
                Type type = (channel as GLib.Object).get_type ();
                Cld.debug ("Received object is Column - %s", type.name ());

                if (channel is ScalableChannel) {
                    var calibration = (channel as ScalableChannel).calibration;
                    cals += "%s:\ty = ".printf (channel.id);

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
    public void write_next_line () {
        string line = "";
        char sep = '\t';
        DateTime curr_time = new DateTime.now_local ();
        TimeSpan diff = curr_time.difference (start_time);
        //int h = (int)diff / 3600000000;
        //int m = (int)diff / 60000000 - (h * 60);
        //int s = (int)diff / 1000000 - (h * 3600 + m * 60);
        //int ms = (int)diff % 1000000;

        //line = "%02d:%02d:%02d.%03d\t".printf (h, m, s, ms);
        line = "%lld\t".printf ((int64)diff);

        foreach (var object in objects.values) {
            if (object is Column) {
                var channel = ((object as Column).channel as Channel);
                if (channel is ScalableChannel) {
                    line += "%f%c".printf ((object as Column).channel_value, sep);
                } else if (channel is DChannel) {
                    if ((channel as DChannel).state)
                        line += "on%c".printf (sep);
                    else
                        line += "off%c".printf (sep);
                }
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
        bg_log.begin ((obj, res) => {
            try {
                bg_log.end (res);
                Cld.debug ("Log file async ended");
            } catch (ThreadError e) {
                string msg = e.message;
                Cld.error (@"Thread error: $msg");
            }
        });
    }

    private async void bg_log () throws ThreadError {
        SourceFunc callback = bg_log.callback;

        ThreadFunc<void *> _run = () => {
            Mutex mutex = new Mutex ();
            Cond cond = new Cond ();
            int64 end_time;

            active = true;
            write_header ();

            while (active) {
                write_next_line ();
                mutex.lock ();
                try {
                    end_time = get_monotonic_time () + dt * TimeSpan.MILLISECOND;
                    while (cond.wait_until (mutex, end_time))
                        ; /* do nothing */
                } finally {
                    mutex.unlock ();
                }
            }

            Idle.add ((owned) callback);
            return null;
        };
        Thread.create<void *> (_run, false);

        yield;
    }

    /**
     * {@inheritDoc}
     */
    public override void stop () {
        if (active) {
            active = false;
            //thread.join ();
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

    /**
     * {@inheritDoc}
     */
    public override void update_objects (Gee.Map<string, Object> val) {
        _objects = val;
    }

    /**
     * {@inheritDoc}
     */
    public override string to_string () {
        string str_data  = "CldLog\n";
               str_data += "\tid:   %s\n".printf (id);
               str_data += "\tname: %s\n".printf (name);
               str_data += "\tpath: %s\n".printf (path);
               str_data += "\tfile: %s\n".printf (file);
               str_data += "\trate: %.3f\n".printf (rate);
        return str_data;
    }
}
