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
    public void file_open () {
        string filename;
        if (!path.has_suffix ("/"))
            path = "%s%s".printf (path, "/");
        filename = "%s%s".printf (path, file);
        /* Open the database file*/
        int ec = Sqlite.Database.open (filename, out db);
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
     * {@inheritDoc}
     */
    public override void start () {
        file_open ();
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
                    coeff [i] = double.MIN;
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
        double val = double.MIN;
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
     */
    public Gee.Map<string, Cld.ExperimentEntry> get_experiments () {
        Gee.Map<string, Cld.ExperimentEntry> experiments = new Gee.HashMap<string, Cld.ExperimentEntry> ();
        string query;

        if (!is_open) {
            file_open ();
        }

        query = "SELECT * from Experiment;";
        ec = db.prepare_v2 (query, query.length, out stmt);
        if (ec != Sqlite.OK) {
            stderr.printf ("Error: %d: %s\n", db.errcode (), db.errmsg ());
        }
        while (stmt.step () == Sqlite.ROW) {
            Cld.ExperimentEntry experiment = new Cld.ExperimentEntry ();
            experiment.experiment_id = stmt.column_int (Experiment_Columns.ID);
            experiment.id = "ee%d".printf (experiment.experiment_id);
            experiment.name = stmt.column_text (Experiment_Columns.NAME);
            experiment.start_date = stmt.column_text (Experiment_Columns.START_DATE);
            experiment.stop_date = stmt.column_text (Experiment_Columns.STOP_DATE);
            experiment.start_time = stmt.column_text (Experiment_Columns.START_TIME);
            experiment.stop_time = stmt.column_text (Experiment_Columns.STOP_TIME);
            experiment.log_rate = stmt.column_double (Experiment_Columns.LOG_RATE);
            experiments.set (experiment.id, experiment);
        }
        stmt.reset ();

        return experiments;
    }

    /**
     * {@inheritDoc}
     */
    public override void update_objects (Gee.Map<string, Object> val) {
        _objects = val;
    }
}
