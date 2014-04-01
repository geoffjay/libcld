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
    private Cld.LogEntry _entry;
    private string _log_name;

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
    public override Gee.Deque<Cld.LogEntry> queue { get; set; }

    /**
     * {@inheritDoc}
     */
    public override Cld.LogEntry entry {
        get { return _entry; }
        set { _entry = value; }
    }

    /**
     * A string value that is the name of the current Log table.
     */
    public string log_name {
        get { return _log_name; }
    }

    /**
     * DateTime data to use for time stamping log entries.
     */
    private DateTime start_time;

    /**
     * A LogEntry that is retrieved from the queue.
     */
    private Cld.LogEntry tail_entry;

    /**
     * An SQLite database object
     */
    private Sqlite.Database db;

    /**
     * An SQLite statement created from a prepared query
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



    /* constructor */
    construct {
        objects = new Gee.TreeMap<string, Object> ();
        entry = new Cld.LogEntry ();
        tail_entry = new Cld.LogEntry ();
        queue = new Gee.LinkedList<Cld.LogEntry> ();

        /* Open the database */
        int ec = Sqlite.Database.open ("test.db", out db);
        if (ec != Sqlite.OK) {
            stderr.printf ("Can't open database: %d: %s\n", db.errcode (), db.errmsg ());
        }

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
        create_tables ();
    }

    public SqliteLog.from_xml_node (Xml.Node *node) {
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
        create_tables ();
    }

    ~CsvLog () {
        if (_objects != null)
            _objects.clear ();
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
                (channel as Cld.ScalableChannel).new_value.connect ((id, value) => {
                    (column as Cld.Column).channel_value = value;
                });
            }
        }
    }

    /**
     * {@inheritDoc}
     */
    public override void start () {
        start_time = new DateTime.now_local ();
        stdout.printf ("start_time: %s\n", start_time.to_string ());
        update_experiment_table ();
        update_channel_table ();
        _log_name = "Log_%s".printf (
            start_time.to_string ().replace ("-", "_").replace (":", "_")
            );

        add_log_table ();
        log_data ();
    }

    private void update_experiment_table () {
        string experiment_name;
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
        experiment_name = "Experiment_%s".printf (start_time.to_string ());
        stmt.bind_text (parameter_index, experiment_name, -1, GLib.g_free);

        parameter_index = stmt.bind_parameter_index ("$STOP_DATE");
        stmt.bind_text (parameter_index, "<none>", -1, GLib.g_free);

        parameter_index = stmt.bind_parameter_index ("$STOP_TIME");
        stmt.bind_text (parameter_index, "<none>", -1, GLib.g_free);

        parameter_index = stmt.bind_parameter_index ("$LOG_RATE");
        stmt.bind_double (parameter_index, rate);

        stdout.printf ("stmt.step () returns: %d\n", stmt.step ());
        stdout.printf ("stmt.reset () returns: %d\n", stmt.reset ());

        query = "SELECT COUNT(id) FROM Experiment;";
        ec = db.prepare_v2 (query, query.length, out stmt);
        if (ec != Sqlite.OK) {
            stderr.printf ("Error: %d: %s\n", db.errcode (), db.errmsg ());
        }

        stdout.printf ("stmt.step () returns: %d\n", stmt.step ());
        experiment_id = int.parse (stmt.column_text (0));
        while (stmt.step () == Sqlite.ROW) {
            stdout.printf ("number of ids in Experiment: %d\n",  experiment_id);
        }
        stdout.printf ("stmt.reset () returns: %d\n", stmt.reset ());
    }

    private void update_channel_table () {
        for (int i = 0; i < 5; i++) {
            string chan_id = "chan_id %d".printf (i);
            string desc = "description %d".printf (i);
            string tag = "tag %d".printf (i);
            string type = "type %d".printf (i);
            string expression = "expression %d".printf (i);
            string coeff_x0 = "coeff_x0 %d".printf (i);
            string coeff_x1 = "coeff_x1 %d".printf (i);
            string coeff_x2 = "coeff_x2 %d".printf (i);
            string coeff_x3 = "coeff_x3 %d".printf (i);

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
            stmt.bind_text (parameter_index, coeff_x0, -1, GLib.g_free);

            parameter_index = stmt.bind_parameter_index ("$COEFF_X1");
            stmt.bind_text (parameter_index, coeff_x1, -1, GLib.g_free);

            parameter_index = stmt.bind_parameter_index ("$COEFF_X2");
            stmt.bind_text (parameter_index, coeff_x2, -1, GLib.g_free);

            parameter_index = stmt.bind_parameter_index ("$COEFF_X3");
            stmt.bind_text (parameter_index, coeff_x3, -1, GLib.g_free);

            stdout.printf ("update_channel_table stmt.step () returns: %d\n", stmt.step ());
            stdout.printf ("update_channel_table stmt.reset () returns: %d\n", stmt.reset ());
        }
    }

    private void log_data () {
        for (int row = 0; row < 10; row++) {
            string query = """
                INSERT INTO %s
                (
                experiment_id,
                time,
                ai0,
                ai1,
                ai2,
                ai3,
                ai4,
                ai5
                )
                VALUES
                (
                $EXPERIMENT_ID,
                TIME ('now', 'localtime'),
                $VAL0,
                $VAL1,
                $VAL2,
                $VAL3,
                $VAL4,
                $VAL5
                );
            """.printf (log_name);
//            stdout.printf ("%s\n", query);
            ec = db.prepare_v2 (query, query.length, out stmt);
            if (ec != Sqlite.OK) {
                stderr.printf ("Error: %d: %s\n", db.errcode (), db.errmsg ());
            }
            parameter_index = stmt.bind_parameter_index ("$EXPERIMENT_ID");
            stmt.bind_int (parameter_index, experiment_id);

            parameter_index = stmt.bind_parameter_index ("$VAL0");
            stmt.bind_double (parameter_index, row);
            parameter_index = stmt.bind_parameter_index ("$VAL1");
            stmt.bind_double (parameter_index, row);
            parameter_index = stmt.bind_parameter_index ("$VAL2");
            stmt.bind_double (parameter_index, row);
            parameter_index = stmt.bind_parameter_index ("$VAL3");
            stmt.bind_double (parameter_index, row);
            parameter_index = stmt.bind_parameter_index ("$VAL4");
            stmt.bind_double (parameter_index, row);
            parameter_index = stmt.bind_parameter_index ("$VAL5");
            stmt.bind_double (parameter_index, row);

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
        """.printf (log_name);

        ec = db.exec (query, null, out errmsg);
        if (ec != Sqlite.OK) {
            stderr.printf ("Error: %s\n", errmsg);
        }

        for (int i = 0; i < 6; i++) {
            string chan_id = "ai%d".printf (i);
            query = "ALTER TABLE %s ADD COLUMN %s REAL;".printf (log_name, chan_id);
            ec = db.exec (query, null, out errmsg);
            if (ec != Sqlite.OK) {
                stderr.printf ("Error: %s\n", errmsg);
            }
        }
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

