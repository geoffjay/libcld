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
 *  Steve Roy <sroy1966@gmail.com>
 */

/**
 * A CSV style log file.
 */
public class Cld.SqliteLog : Cld.AbstractLog {

    /**
     * Property backing fields.
     */
    private Gee.Map<string, Object> _objects;
    private Cld.LogEntry _entry;
    private string _experiment_name;

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
     * A FIFO stack of LogEntry objects.
     */
    private Gee.Deque<Cld.LogEntry> queue { get; set; }

    /**
     * {@inheritDoc}
     */
    public override Cld.LogEntry entry {
        get { return _entry; }
        set { _entry = value; }
    }

    /**
     * The name of the current Log table.
     */
    public string experiment_name {
        get { return _experiment_name; }
    }

    /**
     * A time stamp for log entries.
     */
    private DateTime start_time;

    /**
     * An SQLite database object.
     */
    private Sqlite.Database db;

    /**
     * An SQLite statement created from a prepared query.
     */
    private Sqlite.Statement stmt;

    /**
     * Contains the query that is to be prepared by SQLite.
     */
    private string query;
    private string errmsg;
    private int parameter_index;
    private int ec;
    private int experiment_id;
    /**
     * File stream to use as output to a .csv file.
     */
    private FileStream file_stream;


    /**
     * Enumerated Experiment table column names.
     */
    public enum Experiment_Columns {
        ID          = 0,
        NAME        = 1,
        START_DATE  = 2,
        STOP_DATE   = 3,
        START_TIME  = 4,
        STOP_TIME   = 5,
        LOG_RATE    = 6
    }

    public enum Channel_Columns {
        ID,
        EXPERIMENT_ID,
        CHAN_ID,
        DESC,
        TAG,
        TYPE,
        EXPRESSION,
        COEFF_X0,
        COEFF_X1,
        COEFF_X2,
        COEFF_X3,
        COEFF_X4
    }

    /* constructor */
    construct {
        objects = new Gee.TreeMap<string, Object> ();
        entry = new Cld.LogEntry ();
        queue = new Gee.LinkedList<Cld.LogEntry> ();

    }

    public SqliteLog () {
        id = "database0";
        name = "Log Database File";
        path = "/tmp/";
        file = "log.db";
        rate = 10.0;          /* Hz */
        active = false;
        is_open = false;
        time_stamp = TimeStampFlag.OPEN;
    }

    public SqliteLog.from_xml_node (Xml.Node *node) {
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
     * Open the database file for logging.
     */
    public void database_open () {
        string db_filename;
        if (!path.has_suffix ("/"))
            path = "%s%s".printf (path, "/");
        db_filename = "%s%s".printf (path, file);
        /* Open the database file*/
        int ec = Sqlite.Database.open (db_filename, out db);
        if (ec != Sqlite.OK) {
            stderr.printf ("Can't open database: %d: %s\n", db.errcode (), db.errmsg ());
            is_open = false;
        } else {
            is_open = true;
        }
    }

    /**
     * Create the Experiment and Channel tables if they do not exist.
     */
    private void create_tables () {
        string query = """
            CREATE TABLE IF NOT EXISTS Experiment
            (
            id          INTEGER PRIMARY KEY AUTOINCREMENT,
            name        TEXT,
            start_date  TEXT,
            stop_date   TEXT,
            start_time  TEXT,
            stop_time   TEXT,
            log_rate    REAL
            );
        """;

        ec = db.exec (query, null, out errmsg);
        if (ec != Sqlite.OK) {
            stderr.printf ("Error: %s\n", errmsg);
        }

        query = """
            CREATE TABLE IF NOT EXISTS Channel
            (
            id              INTEGER PRIMARY KEY AUTOINCREMENT,
            experiment_id   INTEGER,
            chan_id         TEXT,
            desc            TEXT,
            tag             TEXT,
            type            TEXT,
            expression      TEXT,
            coeff_x0        REAL,
            coeff_x1        REAL,
            coeff_x2        REAL,
            coeff_x3        REAL,
            FOREIGN KEY(experiment_id) REFERENCES Experiment(id)
            );
        """;

        ec = db.exec (query, null, out errmsg);
        if (ec != Sqlite.OK) {
            stderr.printf ("Error: %s\n", errmsg);
        }
    }

    /**
     * Connect the columns to their corresponding channel signals.
     */
    public void connect_signals () {
        foreach (var column in objects.values) {
            if (column is Cld.Column) {
                var channel = (column as Cld.Column).channel;
                if (channel is Cld.ScalableChannel) {
                    (channel as Cld.ScalableChannel).new_value.connect ((id, value) => {
                        (column as Cld.Column).channel_value = value;
                    });
                } else if (channel is Cld.DChannel) {
                    (channel as Cld.DChannel).new_value.connect ((id, value) => {
                        (column as Cld.Column).channel_value = (double) value;
                    });
                }
            }
        }
    }

    /**
     * Open the file for logging.
     *
     * @return On successful open true, false otherwise.
     */
    public bool file_open (string filename) {
        bool success;
        DateTime created_time = new DateTime.now_local ();

        /* open the file */
        Cld.debug ("filename: %s ", filename);
        file_stream = FileStream.open (filename, "w+");
        if (file_stream == null) {
           // XXX Throw an error?;
           success = false;
        } else {
           // is_open = true;
            /* add the header */
            file_stream.printf ("Log file: %s created at %s\n\n",
                                name, created_time.format ("%F %T"));
            success = true;
        }

        return success;
    }

    /**
     * Writes a standard header to the top of the file.
     */
    public void write_header () {
        Gee.Map<string, Cld.ChannelEntry> channel_entries = new Gee.HashMap<string, Cld.ExperimentEntry> ();
        string tags = "Time";
        //string units = "[HH:MM:SS.mmm]";
        string units = "[us]";
        string cals = "Channel Calibrations:\n\n";

        channel_entries = get_channel_entries (experiment_id);
        foreach (var channel_entry in channel_entries.values) {
            //Cld.debug ("chan_tbl_id: %d chan_id: %s", (channel_entry as Cld.ChannelEntry).chan_tbl_id,
              //                                        (channel_entry as Cld.ChannelEntry).chan_id);

        }

        var header = "%s\nLogging rate: %.2f Hz\n\n%s\n%s\n".printf (cals, rate, tags, units);

//        file_print (header);


//        foreach (var object in objects.values) {
//            Cld.debug ("Found object [%s]", object.id);
//            if (object is Column) {
//                var channel = ((object as Column).channel as Channel);
//                Type type = (channel as GLib.Object).get_type ();
//                Cld.debug ("Received object is Column - %s", type.name ());
//
//                if (channel is ScalableChannel) {
//                    var calibration = (channel as ScalableChannel).calibration;
//                    cals += "%s:\ty = ".printf (channel.id);
//
//                    foreach (var coefficient in (calibration as Container).objects.values) {
//                        cals += "%.3f * x^%d + ".printf (
//                                (coefficient as Coefficient).value,
//                                (coefficient as Coefficient).n
//                            );
//                    }
//
//                    cals = cals.substring (0, cals.length - 3);
//                    cals += "\t(%s)\n".printf (channel.desc);
//                    units += "\t[%s]".printf (calibration.units);
//                    tags += "\t%s".printf (channel.tag);
//                } else if (channel is DChannel) {
//                    tags += "\t%s".printf (channel.tag);
//                }
//            }
//        }
//
//        var header = "%s\nLogging rate: %.2f Hz\n\n%s\n%s\n".printf (cals, rate, tags, units);
//
//        file_print (header);
    }



    /**
     * {@inheritDoc}
     */
    public override void start () {
        database_open ();
        create_tables ();
        start_time = new DateTime.now_local ();
        stdout.printf ("start_time: %s\n", start_time.to_string ());
        _experiment_name = "Experiment_%s".printf (
            start_time.to_string ().replace ("-", "_").replace (":", "_")
            );
        update_experiment_table ();
        update_channel_table ();

        add_log_table ();

        bg_log_timer.begin ((obj, res) => {
            try {
                bg_log_timer.end (res);
                Cld.debug ("Log queue timer async ended");
            } catch (ThreadError e) {
                string msg = e.message;
                Cld.error (@"Thread error: $msg");
            }
        });

        bg_log_watch.begin ((obj, res) => {
            try {
                bg_log_watch.end (res);
                Cld.debug ("Log file watch async ended");
            } catch (ThreadError e) {
                string msg = e.message;
                Cld.error (@"Thread error: $msg");
            }
        });
    }

    /**
     * Launches a backround thread that pushes a LogEntry to the queue at regular time
     * intervals.
     */
    private async void bg_log_timer () throws ThreadError {
        SourceFunc callback = bg_log_timer.callback;

        ThreadFunc<void *> _run = () => {
            Mutex mutex = new Mutex ();
            Cond cond = new Cond ();
            int64 end_time;

            active = true;

            while (active) {
                lock (queue) {
                    entry.update (objects);
                    if (!queue.offer_head (entry))
                        Cld.error ("Element %s was not added to the queue.", entry.id);
                }
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
     * Launches a thread that pulls a LogEntry from the queue and writes
     * it to the log file.
     */
    private async void bg_log_watch () throws ThreadError {
        SourceFunc callback = bg_log_watch.callback;
        Cld.LogEntry tail_entry = new Cld.LogEntry ();

        ThreadFunc<void *> _run = () => {
            active = true;

            while (active) {
                lock (queue) {
                    if (queue.size == 0) {
                        ;
                    } else {
                        tail_entry = queue.poll_tail ();
                        log_entry (tail_entry);
                    }
                }
            }

            Idle.add ((owned) callback);
            return null;
        };
        Thread.create<void *> (_run, false);

        yield;
    }


    private void update_experiment_table () {
        query = """
            INSERT INTO Experiment
            (
            name,
            start_date,
            stop_date,
            start_time,
            stop_time,
            log_rate
            )
            VALUES
            (
            $NAME,
            DATE('now'),
            $STOP_DATE,
            TIME ('now', 'localtime'),
            $STOP_TIME,
            $LOG_RATE
            );
        """;

        ec = db.prepare_v2 (query, query.length, out stmt);
        if (ec != Sqlite.OK) {
            stderr.printf ("Error: %d: %s\n", db.errcode (), db.errmsg ());
        }
        parameter_index = stmt.bind_parameter_index ("$NAME");
        stmt.bind_text (parameter_index, _experiment_name, -1, GLib.g_free);

        parameter_index = stmt.bind_parameter_index ("$STOP_DATE");
        stmt.bind_text (parameter_index, "<none>", -1, GLib.g_free);

        parameter_index = stmt.bind_parameter_index ("$STOP_TIME");
        stmt.bind_text (parameter_index, "<none>", -1, GLib.g_free);

        parameter_index = stmt.bind_parameter_index ("$LOG_RATE");
        stmt.bind_double (parameter_index, rate);

        stmt.step ();
        stmt.reset ();

        query = "SELECT COUNT(id) FROM Experiment;";
        ec = db.prepare_v2 (query, query.length, out stmt);
        if (ec != Sqlite.OK) {
            stderr.printf ("Error: %d: %s\n", db.errcode (), db.errmsg ());
        }

        stmt.step ();
        experiment_id = int.parse (stmt.column_text (0));
        stmt.reset ();
    }

    private void update_channel_table () {
        double[] coeff = new double [4];
        string chan_id = "";
        string desc = "";
        string tag = "";
        string type = "";
        string expression = "";

        foreach (var column in objects.values) {
            if (column is Cld.Column) {
                var channel = (column as Cld.Column).channel;
                chan_id = "%s".printf (channel.id);
                desc = "%s".printf (channel.desc);
                tag = "%s".printf (channel.tag);
                type = "%s".printf (((channel as GLib.Object).get_type ()).name ());
                if (channel is VChannel) {
                    expression = "%s".printf ((channel as VChannel).expression);
                }
                for (int i = 0; i < 4; i++) {
                    coeff [i] = 0;
                    if (channel is ScalableChannel) {
                        var coefficient = (channel as ScalableChannel).calibration.get_coefficient (i);
                        if (coefficient != null) {
                            coeff [i] = (coefficient as Cld.Coefficient).value;
                        }
                    }
                }
            }

            query = """
                INSERT INTO Channel
                (
                experiment_id,
                chan_id,
                desc,
                tag,
                type,
                expression,
                coeff_x0,
                coeff_x1,
                coeff_x2,
                coeff_x3
                )
                VALUES
                (
                $EXPERIMENT_ID,
                $CHAN_ID,
                $DESC,
                $TAG,
                $TYPE,
                $EXPRESSION,
                $COEFF_X0,
                $COEFF_X1,
                $COEFF_X2,
                $COEFF_X3
                );
            """;

            ec = db.prepare_v2 (query, query.length, out stmt);
            if (ec != Sqlite.OK) {
                stderr.printf ("Error: %d: %s\n", db.errcode (), db.errmsg ());
            }
            parameter_index = stmt.bind_parameter_index ("$EXPERIMENT_ID");
            stmt.bind_int (parameter_index, experiment_id);

            parameter_index = stmt.bind_parameter_index ("$CHAN_ID");
            stmt.bind_text (parameter_index, chan_id, -1, GLib.g_free);

            parameter_index = stmt.bind_parameter_index ("$DESC");
            stmt.bind_text (parameter_index, desc, -1, GLib.g_free);

            parameter_index = stmt.bind_parameter_index ("$TAG");
            stmt.bind_text (parameter_index, tag, -1, GLib.g_free);

            parameter_index = stmt.bind_parameter_index ("$TYPE");
            stmt.bind_text (parameter_index, type, -1, GLib.g_free);

            parameter_index = stmt.bind_parameter_index ("$EXPRESSION");
            stmt.bind_text (parameter_index, expression, -1, GLib.g_free);

            parameter_index = stmt.bind_parameter_index ("$COEFF_X0");
            stmt.bind_double (parameter_index, coeff [0]);

            parameter_index = stmt.bind_parameter_index ("$COEFF_X1");
            stmt.bind_double (parameter_index, coeff [1]);

            parameter_index = stmt.bind_parameter_index ("$COEFF_X2");
            stmt.bind_double (parameter_index, coeff [2]);

            parameter_index = stmt.bind_parameter_index ("$COEFF_X3");
            stmt.bind_double (parameter_index, coeff [3]);

            stmt.step ();
            stmt.reset ();
        }
    }

    private void add_log_table () {
        string query = """
            CREATE TABLE IF NOT EXISTS %s
            (
            id              INTEGER PRIMARY KEY AUTOINCREMENT,
            experiment_id   INTEGER,
            time            REAL
            );
        """.printf (_experiment_name);

        ec = db.exec (query, null, out errmsg);
        if (ec != Sqlite.OK) {
            stderr.printf ("Error: %s\n", errmsg);
        }

        foreach (var column in objects.values) {
            if (column is Cld.Column) {
                query = "ALTER TABLE %s ADD COLUMN %s REAL;".printf (_experiment_name,
                                                    (column as Cld.Column).chref);
                ec = db.exec (query, null, out errmsg);
                if (ec != Sqlite.OK) {
                    stderr.printf ("Error: %s\n", errmsg);
                }
            }
        }
    }

    private void log_entry (Cld.LogEntry entry) {
        TimeSpan diff = entry.timestamp.difference (start_time);
        string query = """
            INSERT INTO %s
            (
            experiment_id,
            time,
        """.printf (_experiment_name);

        foreach (var column in objects.values) {
            if (column is Cld.Column) {
                query = "%s%s,".printf (query, (column as Cld.Column).chref);
            }
        }
        query = query.substring (0, query.length - 1);
        query = "%s%s".printf (query, ") VALUES ($EXPERIMENT_ID, $MICROSECONDS,");
        int i = 0;
        foreach (var column in objects.values) {
            if (column is Cld.Column) {
                query = "%s%s".printf (query, "$VAL%d,".printf (i));
            }
            i++;
        }
        query = query.substring (0, query.length - 1);
        query = "%s%s".printf (query, ");");

        ec = db.prepare_v2 (query, query.length, out stmt);
        if (ec != Sqlite.OK) {
            stderr.printf ("Error: %d: %s\n", db.errcode (), db.errmsg ());
        }
        parameter_index = stmt.bind_parameter_index ("$EXPERIMENT_ID");
        stmt.bind_int (parameter_index, experiment_id);

        parameter_index = stmt.bind_parameter_index ("$MICROSECONDS");
        stmt.bind_int (parameter_index, (int) diff);

        i = 0;
        double val = 0;
        foreach (var column in objects.values) {
            if (column is Cld.Column) {
                parameter_index = stmt.bind_parameter_index ("$VAL%d".printf (i));
                var channel = (column as Cld.Column).channel;
                if (channel is Cld.ScalableChannel) {
                    val = (channel as Cld.ScalableChannel).scaled_value;
                } else if (channel is DChannel) {
                    if ((channel as DChannel).state) {
                        val = 1;
                    } else {
                        val = 0;
                    }
                }
                stmt.bind_double (parameter_index, val);
            }
            i++;
        }
        stmt.step ();
        stmt.reset ();
    }

    /**
     * {@inheritDoc}
     */
    public override void stop () {
        query = """
            UPDATE Experiment
            SET stop_date = DATE('now'),
                stop_time = TIME('now', 'localtime')
            WHERE id = %s;
        """.printf (experiment_id.to_string ());

        ec = db.prepare_v2 (query, query.length, out stmt);
        if (ec != Sqlite.OK) {
            stderr.printf ("Error: %d: %s\n", db.errcode (), db.errmsg ());
        }

        stmt.step ();
        stmt.reset ();

        if (active) {
            active = false;
        }
    }

    /**
     * A convenience method to retrieve a list of the Log tables
     * @return A Gee.Map of all Cld.ExperimentEntry entries representing the
     *         row entries in the database Experiment table.
     */
    public Gee.Map<string, Cld.ExperimentEntry> get_experiment_entries () {
        Gee.Map<string, Cld.ExperimentEntry> entries = new Gee.HashMap<string, Cld.ExperimentEntry> ();
        string query;

        if (!is_open) {
            database_open ();
        }

        query = "SELECT * from Experiment;";
        ec = db.prepare_v2 (query, query.length, out stmt);
        if (ec != Sqlite.OK) {
            stderr.printf ("Error: %d: %s\n", db.errcode (), db.errmsg ());
        }
        while (stmt.step () == Sqlite.ROW) {
            Cld.ExperimentEntry entry = new Cld.ExperimentEntry ();
            entry.experiment_id = stmt.column_int (Experiment_Columns.ID);
            entry.id = "ee%d".printf (entry.experiment_id);
            entry.name = stmt.column_text (Experiment_Columns.NAME);
            entry.start_date = stmt.column_text (Experiment_Columns.START_DATE);
            entry.stop_date = stmt.column_text (Experiment_Columns.STOP_DATE);
            entry.start_time = stmt.column_text (Experiment_Columns.START_TIME);
            entry.stop_time = stmt.column_text (Experiment_Columns.STOP_TIME);
            entry.log_rate = stmt.column_double (Experiment_Columns.LOG_RATE);
            entries.set (entry.id, entry);
        }
        stmt.reset ();

        return entries;
    }

    /**
     * Generates a csv data file from an Experiment table in the database
     *
     * @param filename The full path and filename of the csv file.
     * @param experiment_name A database table name of a logged experiment.
     * @param start The start time (in microseconds) for the output csv file.
     * @param stop The stop time (in microseconds) for the output csv file.
     * @param step The time step increment (in microseconds) for the output csv file.
     * @param is_averaged if true the ouput values are average over the time step otherwise a single value is recorded.
     */
    public void export_csv (string filename, int experiment_id, int start, int stop, int step, bool is_averaged) {

        file_open (filename);
        write_header ();
    }

    public Gee.Map<string, Cld.ChannelEntry> get_channel_entries (int experiment_id) {
        Gee.Map<string, Cld.ChannelEntry> entries = new Gee.HashMap<string, Cld.ExperimentEntry> ();
        string query;
        if (!is_open) {
            database_open ();
        }

        query = "SELECT * FROM Channel WHERE experiment_id=%d".printf (experiment_id);
        ec = db.prepare_v2 (query, query.length, out stmt);
        if (ec != Sqlite.OK) {
            stderr.printf ("Error: %d: %s\n", db.errcode (), db.errmsg ());
        }
        while (stmt.step () == Sqlite.ROW) {
            Cld.ChannelEntry entry  = new Cld.ChannelEntry ();
            entry.chan_tbl_id = stmt.column_int (Channel_Columns.ID);
            entry.id = "ce%d".printf (entry.chan_tbl_id);
            entry.experiment_id = stmt.column_int (Channel_Columns.EXPERIMENT_ID);
            entry.chan_id = stmt.column_text (Channel_Columns.CHAN_ID);
            entry.desc = stmt.column_text (Channel_Columns.DESC);
            entry.tag = stmt.column_text (Channel_Columns.TAG);
            entry.cld_type = stmt.column_text (Channel_Columns.TYPE);
            entry.expression = stmt.column_text (Channel_Columns.EXPRESSION);
            entry.coeff_x0 = stmt.column_double (Channel_Columns.COEFF_X0);
            entry.coeff_x1 = stmt.column_double (Channel_Columns.COEFF_X1);
            entry.coeff_x2 = stmt.column_double (Channel_Columns.COEFF_X2);
            entry.coeff_x3 = stmt.column_double (Channel_Columns.COEFF_X3);
            entries.set (entry.id, entry);
        }
        stmt.reset ();

        return entries;
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
