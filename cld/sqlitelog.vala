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
public class Cld.SqliteLog : Cld.AbstractLog {

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
     * {@inheritDoc}
     */
    private override Gee.Deque<Cld.LogEntry> queue { get; set; }

    /**
     * {@inheritDoc}
     */
    private override Cld.LogEntry entry { get; set; }

    /**
     * DateTime data to use for time stamping log entries.
     */
    private DateTime start_time;


    /* constructor */
    public SqliteLog () {
        id = "database0";
        name = "Log Database File";
        path = "/tmp/";
        file = "log.db";
        rate = 10.0;          /* Hz */
        active = false;
        is_open = false;
        time_stamp = TimeStampFlag.OPEN;

        objects = new Gee.TreeMap<string, Object> ();
    }

    public SqliteLog.from_xml_node (Xml.Node *node) {
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
     * {@inheritDoc}
     */
    public override void start () {

    }

    private async void bg_log_timer () throws ThreadError {
        SourceFunc callback = bg_log_timer.callback;

        ThreadFunc<void *> _run = () => {
            Mutex mutex = new Mutex ();
            Cond cond = new Cond ();
            int64 end_time;

            active = true;
            //write_header ();

            while (active) {
                /// update entry
                //entry.update (get_object_map (typeof (Cld.Column)));
                /// add the entry to the queue
                queue.offer (entry);

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
        }
    }

    /**
     * {@inheritDoc}
     */
    public override void update_objects (Gee.Map<string, Object> val) {
        _objects = val;
    }
}

