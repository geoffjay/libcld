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
 * Column class to reference channels to log.
 */
public class Cld.Column : AbstractObject {

    /**
     * {@inheritDoc}
     */
    public override string id { get; set; }

    /**
     * ID reference of the channel associated with this column.
     */
    public string chref { get; set; }

    /**
     * Referenced channel to use.
     */
    public weak Channel channel { get; set; }

    /**
     * Default constructor.
     */
    public Column () {
        id = "col0";
        chref = "ch0";
    }

    public Column.from_xml_node (Xml.Node *node) {
        if (node->type == Xml.ElementType.ELEMENT_NODE &&
            node->type != Xml.ElementType.COMMENT_NODE) {
            id = node->get_prop ("id");
            chref = node->get_prop ("chref");
        }
    }

    public override string to_string () {
        string str_data  = "[%s] : Column\n".printf (id);
               str_data += "\tchref %s\n\n".printf (chref);
        return str_data;
    }
}

/**
 * A CSV style log file.
 */
public class Cld.Log : AbstractContainer {

    /**
     * {@inheritDoc}
     */
    public override string id { get; set; }

    /**
     *
     */
    public string name { get; set; }

    /**
     *
     */
    public string path { get; set; }

    /**
     *
     */
    public string file { get; set; }

    /**
     *
     */
    public double rate { get; set; }

    /**
     * Time between iterations in milliseconds.
     */
    public int dt { get { return (int)(1e3 / rate); } }

    /**
     * Whether or not the log file is currently active.
     */
    public bool active { get; set; default = false; }

    /**
     *
     */
    public string header { get; set; }

    /**
     *
     */
    public bool is_open { get; set; }

    /**
     * Date/Time format to use when renaming the file on close.
     */
    public string date_format { get; set; }

    private Gee.Map<string, Object> _objects;
    public override Gee.Map<string, Object> objects {
        get { return (_objects); }
        set { update_objects (value); }
    }

    /**
     * Internal thread data for log file output handling.
     */
    private unowned GLib.Thread<void *> thread;
    private Mutex mutex = new Mutex ();

    /**
     * File stream to use as output.
     */
    private FileStream file_stream;

    /**
     * DateTime data to use for time stamping log entries.
     */
    private DateTime start_time;

    /* constructor */
    public Log () {
        id = "log0";
        name = "Log File";
        path = "/tmp/";
        file = "log.csv";
        rate = 10.0;          /* Hz */
        active = false;
        is_open = false;

        objects = new Gee.TreeMap<string, Object> ();
    }

    public Log.from_xml_node (Xml.Node *node) {
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

    /**
     * Print a string to the log file.
     *
     * @param toprint The string to print
     */
    public void file_print (string toprint) {
        file_stream.printf ("%s", toprint);
    }

    /**
     * Open the file for logging.
     *
     * @return On successful open true, false otherwise.
     */
    public bool file_open () {
        string filename;
        DateTime time = new DateTime.now_local ();

        /* original implementation checked for the existence of requested
         * file and posted error message if it is, reimplement that later */
        if (path.has_suffix ("/"))
            filename = "%s%s".printf (path, file);
        else
            filename = "%s/%s".printf (path, file);

        file_stream = FileStream.open (filename, "w+");
        if (file_stream == null)
            is_open = false;
        else
        {
            is_open = true;
            start_time = new DateTime.now_local ();
            /* add the header */
            file_stream.printf ("Log file: %s created at %s\n\n",
                                name, time.format ("%F %T"));
        }

        return is_open;
    }

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
            start_time = null;
        }
    }

    public bool file_is_open () {
        return is_open;
    }

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
        dest = "%s%s-%s.%s".printf (path, dest_name, time.format (date_format), dest_ext);
        if (path.has_suffix ("/"))
            src = "%s%s".printf (path, file);
        else
            src = "%s/%s".printf (path, file);

        /* rename the file */
        if (FileUtils.rename (src, dest) < 0)
            stderr.printf ("An error occurred while renaming " +
                           "the file: %s%s", path, file);

        /* and recreate the original file if requested */
        if (reopen)
            file_open ();
    }

    public void write_header () {
        string tags = "Time";
        //string units = "[HH:MM:SS.mmm]";
        string units = "[us]";
        string cals = "Channel Calibrations:\n\n";

        foreach (var object in objects.values) {
            stdout.printf ("Found object [%s]\n", object.id);
            if (object is Column) {
                var channel = ((object as Column).channel as Channel);
                Type type = (channel as GLib.Object).get_type ();
                stdout.printf ("Received object is Column - %s\n", type.name ());

                if (channel is AChannel) {
                    stdout.printf ("Column channel reference is analog\n");
                    var calibration = (channel as AChannel).calibration;
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
                }
            }
        }

        header = "%s\nLogging rate: %.2f Hz\n\n%s\n%s\n".printf (cals, rate, tags, units);

        file_print (header);
    }

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
                if (channel is AChannel) {
                    line += "%f%c".printf ((channel as AChannel).scaled_value, sep);
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
     * Run the log file output as a thread.
     */
    public void run () {
        if (!GLib.Thread.supported ()) {
            stderr.printf ("Cannot run logging without thread support.\n");
            active = false;
            return;
        }

        if (!active) {
            var log_thread = new Thread (this);

            try {
                active = true;
                write_header ();
                thread = GLib.Thread.create<void *> (log_thread.run, true);
            } catch (ThreadError e) {
                stderr.printf ("%s\n", e.message);
                active = false;
                return;
            }
        }
    }

    /**
     * Stop a PID control loop that is executing.
     */
    public void stop () {
        if (active) {
            active = false;
            thread.join ();
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
    public override void add (Object object) {
        objects.set (object.id, object);
    }

    /**
     * {@inheritDoc}
     */
    public override Object? get_object (string id) {
        Object? result = null;

        if (objects.has_key (id)) {
            result = objects.get (id);
        } else {
            foreach (var object in objects.values) {
                if (object is Container) {
                    result = (object as Container).get_object (id);
                    if (result != null) {
                        break;
                    }
                }
            }
        }

        return result;
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

    public class Thread {
        private Log log;

        public Thread (Log log) {
            this.log = log;
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

            while (log.active) {
                lock (log) {
                    log.write_next_line ();
                }

                mutex.lock ();
                try {
#if HAVE_GLIB232
                    end_time = get_monotonic_time () + log.dt * TimeSpan.MILLISECOND;
                    while (cond.wait_until (mutex, end_time))
#else
                    next_time.add (log.dt * (long)TimeSpan.MILLISECOND);
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

/**
 * A log file entry class which will be pushed onto the tail of the
 * buffer for log file writes.
 **/
public class Cld.Entry : GLib.Object {
    private string _as_string;
    public string as_string {
        get { return _as_string; }
        set { _as_string = value; }
    }
}

/**
 * A log file buffer class to use to be able to write data to a log
 * file without using a rate timer.
 **/
public class Cld.Buffer<G> : GLib.Queue<G> {
}
