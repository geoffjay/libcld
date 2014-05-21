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
     * {linheritDoc}
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
    public override Gee.Map<string, Cld.Object> objects {
        get { return (_objects); }
        set { update_objects (value); }
    }

    /**
     * File path to backup location.
     */
    public string backup_path;

    /**
     * Backup file name.
     */
    public string backup_file;

    /**
     * The interval at which the database will be automativcally backed up.
     */
    public int backup_interval_ms;


    /**
     * The name of the current Log table.
     */
    public string experiment_name {
        get { return _experiment_name; }
    }

    /**
     * A FIFO stack of LogEntry objects.
     */
    private Gee.Deque<Cld.LogEntry> queue { get; set; }

    /**
     * A time stamp for log entries.
     */
    private DateTime start_time;

    /**
     * An SQLite database object for logging data.
     */
    private Sqlite.Database db;

    /**
     * An SQLite database object for backups.\
     */
    private Sqlite.Database backup_db;

    /**
     * An SQLite statement created from a prepared query.
     */
    private Sqlite.Statement stmt;

    /**
     * An SQLite error message;
     */
    private string errmsg;

    /**
     * Used for binding a parameter to an SQLite prepared statement.
     */
    private int parameter_index;

    /**
     * An SQLite error code;
     */
    private int ec;

    /**
     * The id frome the Experiment table of the experiment that is
     * currently logging data. This should not be used for querying
     * the database
     */
    private int experiment_id;

    /**
     * File stream to use as output to a .csv file.
     */
    private FileStream file_stream;


    /**
     * Flag if backup database is open.
     */
    private bool backup_is_open;

    /**
     * Enumerated Experiment table column names.
     */
    public enum ExperimentColumn {
        ID,
        NAME,
        START_DATE,
        STOP_DATE,
        START_TIME,
        STOP_TIME,
        LOG_RATE
    }

    /**
     * Enumerated Channel table column names.
     */
    public enum ChannelColumn {
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
        UNITS
    }

    /**
     * Enumerated subset of the column names in an experiment table.
     */
    public enum ExperimentDataColumns {
        ID,
        EXPERIMENT_ID,
        TIME,
        DATA0
    }

    /**
     * Report the backup progress.
     * % Completion = 100% * (pagecount - remaining) / pagecount
     */
    public signal void backup_progress_updated (int remaining, int pagecount);

    /* constructor */
    construct {
        objects = new Gee.TreeMap<string, Object> ();
        Cld.LogEntry entry = new Cld.LogEntry ();
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
                        case "backup-path":
                            backup_path = iter->get_content ();
                            break;
                        case "backup-file":
                            backup_file = iter->get_content ();
                            break;
                        case "backup-interval-hrs":
                            value = iter->get_content ();
                            backup_interval_ms = (int) (double.parse (value) *
                                                  60 * 60 * 1000);
Cld.debug ("backup interval in ms = %d", backup_interval_ms);
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

    ~SqliteLog () {
        if (_objects != null) {
            _objects.clear ();
        }
    }

    /**
     * Open the database file for logging.
     */
    public void database_open () throws Cld.FileError {
        string db_filename;
        if (!path.has_suffix ("/")) {
            path = "%s%s".printf (path, "/");
        }
        db_filename = "%s%s".printf (path, file);
        if (!(Posix.access (db_filename, Posix.W_OK) == 0) &&
           !(Posix.access (db_filename, Posix.R_OK) == 0)) {
            throw new Cld.FileError.ACCESS (
                    "Can't open database file %s", db_filename
                );
            is_open = false;

            return;
        } else {
            /* Open the database file*/
            int ec = Sqlite.Database.open (db_filename, out db);
            if (ec != Sqlite.OK) {
                Cld.error ("Can't open database: %d: %s\n", db.errcode (), db.errmsg ());
                is_open = false;
            } else {
                is_open = true;
            }
        }
    }

    /**
     * Create the Experiment and Channel tables if they do not exist.
     */
    private void create_tables () {
        string query = """
            CREATE TABLE IF NOT EXISTS experiment
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
            CREATE TABLE IF NOT EXISTS channel
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
                units           TEXT,
                FOREIGN KEY(experiment_id) REFERENCES experiment(id)
            );
        """;

        ec = db.exec (query, null, out errmsg);
        if (ec != Sqlite.OK) {
            stderr.printf ("Error: %s\n", errmsg);
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
//        if ((Posix.access (Posix.R_OK) != 0) ||
//            (Posix.access (Posix.W_OK) != 0)) {
//            throw new Cld.FileError.ACCESS (
//                "Requested access to %s is not permitted.", filename);
//        }
        file_stream = FileStream.open (filename, "w+");
        if (file_stream == null) {
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
     * Print a string to the log file.
     *
     * @param toprint The string to print
     */
    public void file_print (string toprint) {
        if (true) {
            lock (file_stream) {
                file_stream.printf ("%s", toprint);
            }
        }
    }


    /**
     * Writes a standard header to the top of the file.
     * @param id The unique id from the Experiment table.
     */
    public void write_header (int id) {
        Gee.ArrayList<Cld.ChannelEntry?> channel_entries = new Gee.ArrayList<Cld.ChannelEntry?> ();
        string tags = "Time";
        //string units = "[HH:MM:SS.mmm]";
        string units = "[us]";
        string cals = "Channel Calibrations:\n\n";
        string expressions = "MathChannel Expressions:\n\n";

        channel_entries = get_channel_entries (id);
        foreach (var channel_entry in channel_entries) {
            cals += "%s:\ty = ".printf (channel_entry.chan_id);
            cals += "%.3f * x^0 + ".printf (channel_entry.coeff_x0);
            cals += "%.3f * x^1 + ".printf (channel_entry.coeff_x1);
            cals += "%.3f * x^2 + ".printf (channel_entry.coeff_x2);
            cals += "%.3f * x^3 + ".printf (channel_entry.coeff_x3);
            cals = cals.substring (0, cals.length - 3);
            cals += "\t(%s)\n".printf (channel_entry.desc);
            tags += "\t%s".printf (channel_entry.tag);
            if (channel_entry.cld_type == "CldMathChannel") {
                expressions += "%s:\t %s\n".printf (channel_entry.chan_id,
                                                    channel_entry.expression);
            }
            units += "\t[%s]".printf (channel_entry.units);
        }
        var header = "%s\n%s\nLogging rate: %.2f Hz\n\n%s\n%s\n".printf (cals,
                                                            expressions, rate, tags, units);

       file_print (header);
    }

    /**
     * {@inheritDoc}
     */
    public override void start () {
        database_open ();
        create_tables ();
        start_time = new DateTime.now_local ();
        stdout.printf ("start_time: %s\n", start_time.to_string ());
        _experiment_name = "experiment_%s".printf (
            start_time.to_string ().replace ("-", "_").replace (":", "_")
            );
        update_experiment_table ();
        update_channel_table ();
        add_log_table ();
        GLib.Timeout.add_full (GLib.Priority.DEFAULT_IDLE, backup_interval_ms, backup_cb);
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
     * A callback function that automatically backs up the database.
     */
    private bool backup_cb () {
        backup_database.begin ();
        if (active) {

            return true;
        } else {

            return false;
        }
    }


    /**
     * Launches a backround thread that pushes a LogEntry to the queue at regular time
     * intervals.
     */
    private async void bg_log_timer () throws ThreadError {
        SourceFunc callback = bg_log_timer.callback;
        Cld.LogEntry entry = new Cld.LogEntry ();

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
        Cld.LogEntry entry = new Cld.LogEntry ();

        ThreadFunc<void *> _run = () => {
            active = true;

            while (active) {
                lock (queue) {
                    if (queue.size == 0) {
                        ;
                    } else {
                        entry = queue.poll_tail ();
                        log_entry_write (entry);
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
        string query = """
            INSERT INTO experiment
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

        query = "SELECT COUNT(id) FROM experiment;";
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
        string units = "";
        string query;

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
                if (channel is ScalableChannel) {
                    units = "%s".printf ((channel as ScalableChannel).calibration.units);
                    for (int i = 0; i < 4; i++) {
                        coeff [i] = 0;
                        var coefficient = (channel as ScalableChannel).calibration.get_coefficient (i);
                        if (coefficient != null) {
                            coeff [i] = (coefficient as Cld.Coefficient).value;
                        }
                    }
                }
            }

            query = """
                INSERT INTO channel (
                    experiment_id,
                    chan_id,
                    desc,
                    tag,
                    type,
                    expression,
                    coeff_x0,
                    coeff_x1,
                    coeff_x2,
                    coeff_x3,
                    units
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
                    $COEFF_X3,
                    $UNITS
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

            parameter_index = stmt.bind_parameter_index ("$UNITS");
            stmt.bind_text (parameter_index, units, -1, GLib.g_free);

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
                time            TEXT
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

    private void log_entry_write (Cld.LogEntry entry) {
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
        query = "%s%s".printf (query, ") VALUES ($EXPERIMENT_ID, $TIME,");
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

        parameter_index = stmt.bind_parameter_index ("$TIME");
        stmt.bind_text (parameter_index, entry.time_as_string);

        i = 0;
        double val = 0;
//        /* sort objects */
//        Gee.List<Cld.Object> map_values = new Gee.ArrayList<Cld.Object> ();
//
//        map_values.add_all (objects.values);
//        map_values.sort ((GLib.CompareFunc) Cld.Object.compare);
//        objects.clear ();
//        foreach (Cld.Object object in map_values) {
//            objects.set (object.id, object);
//        }

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
     * Get a single entry from an Experiment.
     * @param table_name The table name of the experiment.
     * @param exp_id The SQL id of the experiment from the Experiment table.
     * @param entry_id The unique id of an entry in the table.
     *
     * @return A Cld.LogEntry containg row data from the table.
     */
    private Cld.LogEntry get_log_entry (string table_name, int exp_id, int entry_id) {
        string query;
        Cld.LogEntry ent = new Cld.LogEntry ();
        Gee.ArrayList<double?> data_list = new Gee.ArrayList<double?> ();


        /* Count the number of columns in the table */
        query = "SELECT Count (*) FROM channel WHERE experiment_id=$EXPERIMENT_ID;";
        ec = db.prepare_v2 (query, query.length, out stmt);
        if (ec != Sqlite.OK) {
            stderr.printf ("Error: %d: %s\n", db.errcode (), db.errmsg ());
        }
        parameter_index = stmt.bind_parameter_index ("$EXPERIMENT_ID");
        stmt.bind_int (parameter_index, exp_id);
        stmt.step ();
        int columns = int.parse (stmt.column_text (0));
        stmt.reset ();

        query = "SELECT * FROM %s WHERE id=$ID;".printf (table_name);
        ec = db.prepare_v2 (query, query.length, out stmt);
        if (ec != Sqlite.OK) {
            stderr.printf ("Error: %d: %s\n", db.errcode (), db.errmsg ());
        }
        parameter_index = stmt.bind_parameter_index ("$ID");
        stmt.bind_int (parameter_index, entry_id);

        while (stmt.step () == Sqlite.ROW) {
            ent.time_as_string = stmt.column_text (ExperimentDataColumns.TIME);
            for (int i = 0; i < columns; i++) {
                data_list.add (stmt.column_double (i + 3));
            }
            ent.data = data_list;
        }
        stmt.reset ();

        return ent;
    }


    /**
     * {@inheritDoc}
     */
    public override void stop () {
        string query = """
            UPDATE experiment
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
    public Gee.ArrayList<Cld.ExperimentEntry?> get_experiment_entries () {
        Gee.ArrayList<Cld.ExperimentEntry?> entries = new Gee.ArrayList<Cld.ExperimentEntry?> ();
        string query;

        if (!is_open) {
            try {
                database_open ();
            } catch (Cld.FileError e) {
                if (e is Cld.FileError.ACCESS) {
                    Cld.error ("File access error: %s%s", path, file);
                    is_open = false;

                    return null;
                } else {
                    is_open = true;
                }
            }
        }

        query = "SELECT * FROM experiment;";
        ec = db.prepare_v2 (query, query.length, out stmt);
        if (ec != Sqlite.OK) {
            stderr.printf ("Error: %d: %s\n", db.errcode (), db.errmsg ());
        }
        while (stmt.step () == Sqlite.ROW) {
            Cld.ExperimentEntry ent = Cld.ExperimentEntry ();
            ent.id = stmt.column_int (ExperimentColumn.ID);
            ent.name = stmt.column_text (ExperimentColumn.NAME);
            ent.start_date = stmt.column_text (ExperimentColumn.START_DATE);
            ent.stop_date = stmt.column_text (ExperimentColumn.STOP_DATE);
            ent.start_time = stmt.column_text (ExperimentColumn.START_TIME);
            ent.stop_time = stmt.column_text (ExperimentColumn.STOP_TIME);
            ent.log_rate = stmt.column_double (ExperimentColumn.LOG_RATE);
            entries.add (ent);
        }
        stmt.reset ();

        return entries;
    }

    public Gee.ArrayList<Cld.ChannelEntry?> get_channel_entries (int experiment_id) {
        Gee.ArrayList<Cld.ChannelEntry?> entries = new Gee.ArrayList<Cld.ChannelEntry?> ();
        string query;
        if (!is_open) {
            database_open ();
        }

        query = "SELECT * FROM channel WHERE experiment_id=%d".printf (experiment_id);
        ec = db.prepare_v2 (query, query.length, out stmt);
        if (ec != Sqlite.OK) {
            stderr.printf ("Error: %d: %s\n", db.errcode (), db.errmsg ());
        }
        while (stmt.step () == Sqlite.ROW) {
            Cld.ChannelEntry ent  = Cld.ChannelEntry ();
            ent.id = stmt.column_int (ChannelColumn.ID);
            ent.experiment_id = stmt.column_int (ChannelColumn.EXPERIMENT_ID);
            ent.chan_id = stmt.column_text (ChannelColumn.CHAN_ID);
            ent.desc = stmt.column_text (ChannelColumn.DESC);
            ent.tag = stmt.column_text (ChannelColumn.TAG);
            ent.cld_type = stmt.column_text (ChannelColumn.TYPE);
            ent.expression = stmt.column_text (ChannelColumn.EXPRESSION);
            ent.coeff_x0 = stmt.column_double (ChannelColumn.COEFF_X0);
            ent.coeff_x1 = stmt.column_double (ChannelColumn.COEFF_X1);
            ent.coeff_x2 = stmt.column_double (ChannelColumn.COEFF_X2);
            ent.coeff_x3 = stmt.column_double (ChannelColumn.COEFF_X3);
            ent.units = stmt.column_text (ChannelColumn.UNITS);
            entries.add (ent);
        }
        stmt.reset ();

        return entries;
    }

    /**
     * Backup the database to the location provided.
     */
    public async void backup_database () {
        if (!is_open) {
            database_open ();
        }

        /* TODO: Create method to open database file */
        if (!backup_is_open) {
            backup_open ();
        }

        var backup = new Sqlite.Backup (backup_db, "main", db, "main");

        /* Stepping the database avoids locking the database preventing it from
         * writing to the backup. */
        int ret = 0;
            do {
                ret = backup.step (5);
                backup_progress_updated (backup.remaining (), backup.pagecount ());
                if (ret == Sqlite.OK || ret == Sqlite.BUSY || ret == Sqlite.LOCKED) {
                    Idle.add_full (GLib.Priority.DEFAULT_IDLE, backup_database.callback);
                    yield;
                }
            } while (ret == Sqlite.OK || ret == Sqlite.BUSY || ret == Sqlite.LOCKED);
            backup_is_open = false;

            return;
    }

    /**
     * Open the backup database file.
     */
    public void backup_open () throws Cld.FileError {
        string db_filename;
        if (!backup_path.has_suffix ("/")) {
            backup_path = "%s%s".printf (backup_path, "/");
        }
        var now = new DateTime.now_local ();
        string stamp = now.to_string ();
        db_filename = "%s%s%s".printf (backup_path, backup_file, stamp);
        if (!(Posix.access (db_filename, Posix.F_OK) == 0)) { // if file doesn't exist...
            FileStream.open (db_filename, "a+");
        }
        if (!(Posix.access (db_filename, Posix.W_OK) == 0) &&
           !(Posix.access (db_filename, Posix.R_OK) == 0)) {
            throw new Cld.FileError.ACCESS (
                    "Can't open database file %s: %d: %s", db_filename
                );
            backup_is_open = false;

            return;
        } else {
            /* Open the database file*/
            int ec = Sqlite.Database.open (db_filename, out backup_db);
            if (ec != Sqlite.OK) {
                stderr.printf ("Can't open database: %d: %s\n", backup_db.errcode (),
                    backup_db.errmsg ());
                backup_is_open = false;
            } else {
                backup_is_open = true;
            }
        }
    }

    /**
     * Generates a csv data file from an Experiment table in the database
     *
     * @param filename The full path and filename of the csv file.
     * @param exp_id A database table name of a logged experiment.
     * @param start The start time for the output csv file.
     * @param stop The stop time for the output csv file.
     * @param step The time step increment (in microseconds) for the output csv file.
     * @param is_averaged if true the ouput values are average over the time step otherwise a single value is recorded.
     */
    public void export_csv (string filename,
                            int exp_id_begin,
                            int exp_id_end,
                            DateTime start, DateTime stop, int step,
                            bool is_averaged) {
        string query;
        string name = "";
        string line = "";
        char sep = '\t';
        int count = 0;

        file_open (filename);
        for (int exp_id = exp_id_begin; exp_id < exp_id_end; exp_id++) {
            write_header (exp_id);

            /* Get the table name of the experiment */
            query = "SELECT * FROM experiment WHERE id=$ID;";
            ec = db.prepare_v2 (query, query.length, out stmt);
            if (ec != Sqlite.OK) {
                stderr.printf ("Error: %d: %s\n", db.errcode (), db.errmsg ());
            }
            parameter_index = stmt.bind_parameter_index ("$ID");
            stmt.bind_int (parameter_index, exp_id);

            while (stmt.step () == Sqlite.ROW) {
               name = stmt.column_text (ExperimentColumn.NAME);
            }
            stmt.reset ();

            /* Count the number of columns in the table */
            query = "SELECT Count (*) FROM channel WHERE experiment_id=$EXPERIMENT_ID;";
            ec = db.prepare_v2 (query, query.length, out stmt);
            if (ec != Sqlite.OK) {
                stderr.printf ("Error: %d: %s\n", db.errcode (), db.errmsg ());
            }
            parameter_index = stmt.bind_parameter_index ("$EXPERIMENT_ID");
            stmt.bind_int (parameter_index, exp_id);
            stmt.step ();
            int columns = int.parse (stmt.column_text (0));
            stmt.reset ();

            /* Select data between start and stop time boundaries. */
            query = """
                SELECT * FROM %s
                WHERE datetime (time)
                BETWEEN datetime ("%s")
                AND datetime ("%s")
                ;
            """.printf (name, start.to_string ().substring (0, 19),
                        stop.to_string ().substring (0, 19));
            Cld.debug ("%s", query);
            ec = db.prepare_v2 (query, query.length, out stmt);
            if (ec != Sqlite.OK) {
                stderr.printf ("Error: %d: %s\n", db.errcode (), db.errmsg ());
            }

            while (stmt.step () == Sqlite.ROW) {
                line = "%s\t".printf (stmt.column_text (ExperimentDataColumns.TIME));
                for (int column = 0; column < columns; column++) {
                    line += "%f%c".printf (stmt.column_double (column +
                                            ExperimentDataColumns.DATA0), sep);
                }
                line += "\n";
                file_print (line);
            }
            stmt.reset ();
        }
        file_close ();

        /* Build data strings from query result. */

//        if (is_averaged) {
//            for (int row = 1; row < (count + 1) ; row++) {
//                int i = 1;
//                while (i < step) {
//                    ent = get_log_entry (name, exp_id, row);
//                    if ((ent.time >= start) && (ent.time <= stop)) {
//                    }
//                }
//            }
//        } else {
//        for (int row = 1; row < (count + 1); row += step) {
//            ent = get_log_entry (name, exp_id, row);
//            if ((ent.time_us >= start) && (ent.time_us <= stop)) {
//                line = "%lld\t".printf ((int64)ent.time_us);
//                foreach (double datum in ent.data) {
//                    line += "%f%c".printf (datum, sep);
//                }
//                line += "\n";
//            }
//            file_print (line);
//        }
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
