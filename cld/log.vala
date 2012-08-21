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
public class Cld.Log : AbstractObject {
    /* properties */
    [Property(nick = "ID", blurb = "Log ID")]
    public override string id { get; set; }

    [Property(nick = "Name", blurb = "Log Name")]
    public string name { get; set; }

    [Property(nick = "Path", blurb = "Log Path")]
    public string path { get; set; }

    [Property(nick = "File", blurb = "Log File")]
    public string file { get; set; }

    [Property(nick = "Rate", blurb = "Log Rate")]
    public double rate { get; set; }

    [Property(nick = "Active", blurb = "Is the log file active")]
    public bool active { get; set; }

    [Property(nick = "Header", blurb = "Log File Header")]
    public string header { get; set; }

    public FileStream file_stream;
    public bool is_open;

    /* constructor */
    public Log () {
        id = "log0";
        name = "Log File";
        path = "/tmp/";
        file = "log.csv";
        rate = 10.0;          /* Hz */
        active = false;
        is_open = false;
    }

    public Log.from_xml_node (Xml.Node *node) {
        string value;

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
                        default:
                            break;
                    }
                }
            }
        }
    }

        public void file_print (string toprint) {
            file_stream.printf ("%s", toprint);
        }

        public bool file_open () {
            string filename;
            TimeVal time = TimeVal ();

            /* original implementation checked for the existence of requested
             * file and posted error message if it it, reimplement that later */
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
            /* add the header */
            time.get_current_time ();
            file_stream.printf ("Log file: %s created at %s\n\n",
               name, time.to_iso8601 ());
        }

        return is_open;
    }

    public void file_close () {
        TimeVal time = TimeVal ();

        /* add the footer */
        time.get_current_time ();
        file_stream.printf ("\nLog file: %s closed at %s",
                            name, time.to_iso8601 ());
        /* setting a GLib.FileStream object to null apparently forces a
         * call to stdlib's close () */
        file_stream = null;
        is_open = false;
    }

    public bool file_is_open () {
        return is_open;
    }

    public void file_mv_and_date (bool reopen) {
        string src;
        string dest;
        string dest_name;
        string dest_ext;
        time_t tm = time_t ();
        var t = Time.local (tm);

        /* call to close writes the footer and sets the stream to null */
        file_close ();

        /* generate new file name to move to based on date and
           existing name */
        disassemble_filename (file, out dest_name, out dest_ext);
        dest = "%s%s-%d%02d%02d-%02dh%02dm%02ds.%s".printf (path,
                    dest_name, t.year, t.month+1, t.day, t.hour,
                    t.minute, t.second, dest_ext);
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

    public override string to_string () {
        string str_data  = "CldLog\n";
               str_data += "──┬───\n";
               str_data += "  ├ [id  ] : %s\n".printf (id);
               str_data += "  ├ [name] : %s\n".printf (name);
               str_data += "  ├ [path] : %s\n".printf (path);
               str_data += "  ├ [file] : %s\n".printf (file);
               str_data += "  ├ [rate] : %.3f\n".printf (rate);
        return str_data;
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
