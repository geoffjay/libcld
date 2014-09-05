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
    private string _experiment_name;

    /**
     * Determines whether the file is renamed on open using the format string.
     */
    public Log.TimeStampFlag time_stamp { get; set; }

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
     * An SQLite prepared statement for writing log data.
     */
    private Sqlite.Statement log_stmt;

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
     * A FIFO for holding data to be processed.
     */
    private Gee.Deque<ushort> queue;

    /**
     * The total number of channels in this log.
     */
    private int num_chans;

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
        CHAN_URI,
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
        Cld.LogEntry entry = new Cld.LogEntry ();
        queue = new Gee.LinkedList<ushort> ();
    }

    public SqliteLog () {
        id = "database0";
        name = "Log Database File";
        path = "./";
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
                            break;
                        case "fifo":
                            fifos.set (iter->get_content (), -1);
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

        /* Create the file if it doesn't exist already */
        if (!(Posix.access (db_filename, Posix.F_OK) == 0)) {
            FileStream.open (db_filename, "a+");
        }

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

        /* XXX Memory mapped I/O doesn't seem to improve performance. */
//        string query = "PRAGMA mmap_size=536870912;";
//        ec = db.exec (query, null, out errmsg);
//        if (ec != Sqlite.OK) {
//            stderr.printf ("Error: %s\n", errmsg);
//        }

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
                chan_uri        TEXT,
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
        string units = "[YYYY-MM-DD HH:MM:SS.SSSSSS]";
        string cals = "Channel Calibrations:\n\n";
        string expressions = "MathChannel Expressions:\n\n";

        channel_entries = get_channel_entries (id);
        foreach (var channel_entry in channel_entries) {
            cals += "%s:\ty = ".printf (channel_entry.chan_uri.replace ("_", "/"));
            cals += "%.3f * x^0 + ".printf (channel_entry.coeff_x0);
            cals += "%.3f * x^1 + ".printf (channel_entry.coeff_x1);
            cals += "%.3f * x^2 + ".printf (channel_entry.coeff_x2);
            cals += "%.3f * x^3 + ".printf (channel_entry.coeff_x3);
            cals = cals.substring (0, cals.length - 3);
            cals += "\t(%s)\n".printf (channel_entry.desc);
            tags += "\t%s".printf (channel_entry.tag);
            if (channel_entry.cld_type == "CldMathChannel") {
                expressions += "%s:\t %s\n".printf (channel_entry.chan_uri,
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
        /* Count the number of channels */
        var columns = get_children (typeof (Cld.Column));
        num_chans = columns.size;

        active = true;
        /* Open the FIFO data buffers. */
        foreach (string fname in fifos.keys) {
            open_fifo.begin (fname, (obj, res) => {
                try {
                    int fd = open_fifo.end (res);
                    Cld.debug ("got a writer for %s", fname);

                    /* Background fifo watch */
                    bg_fifo_watch.begin (fd, (obj, res) => {
                        try {
                            bg_fifo_watch.end (res);
                            Cld.debug ("Log fifo watch async ended");
                        } catch (ThreadError e) {
                            string msg = e.message;
                            Cld.error (@"Thread error: $msg");
                        }
                    });

                } catch (ThreadError e) {
                    string msg = e.message;
                    Cld.error (@"Thread error: $msg");
                }
            });
        }

        database_open ();
        create_tables ();
        start_time = new DateTime.now_local ();
        _experiment_name = "experiment_%s".printf (
            start_time.to_string ().replace ("-", "_").replace (":", "_")
            );
        update_experiment_table ();
        update_channel_table ();
        add_log_table ();

        GLib.Timeout.add_full (GLib.Priority.DEFAULT_IDLE, backup_interval_ms, backup_cb);

        bg_process_data.begin ((obj, res) => {
            try {
                bg_process_data.end (res);
                Cld.debug ("Log queue data processing async ended");
            } catch (ThreadError e) {
                string msg = e.message;
                Cld.error (@"Thread error: $msg");
            }
        });
    }

    private async int open_fifo (string fname) {
        SourceFunc callback = open_fifo.callback;
        int fd = -1;

        GLib.Thread<int> thread = new GLib.Thread<int> ("open_fifo_%s".printf (fname), () => {
            Cld.debug ("%s is is waiting for a writer to FIFO %s",this.id, fname);
            fd = Posix.open (fname, Posix.O_RDONLY);
            fifos.set (fname, fd);
            if (fd == -1) {
                Cld.debug ("%s Posix.open error: %d: %s",id, Posix.errno, Posix.strerror (Posix.errno));
            } else {
                Cld.debug ("Sqlite log is opening FIFO %s fd: %d", fname, fd);
            }

            Idle.add ((owned) callback);

            return 0;
        });
        yield;

        return fd;
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
     * Launches a thread that pulls a rows of data from the data FIFO and writes
     * it a queue.
     */
    private async void bg_fifo_watch (int fd) throws ThreadError {
        SourceFunc callback = bg_fifo_watch.callback;
        int ret = -1;
        int bufsz = 65536;
        int total = 0;

	    Posix.fcntl (fd, Posix.F_SETFL, Posix.O_NONBLOCK);

        GLib.Thread<int> thread = new GLib.Thread<int> ("bg_fifo_watch",  () => {

            while (active) {
                ushort[] buf = new ushort[bufsz];
                Posix.fd_set rdset;
                //Posix.timeval timeout = Posix.timeval ();
                Posix.timespec timeout = Posix.timespec ();
                Posix.FD_ZERO (out rdset);
                Posix.FD_SET (fd, ref rdset);
                timeout.tv_sec = 0;
                //timeout.tv_usec = 50000;
                timeout.tv_nsec = 50000000;
                Posix.sigset_t sigset = new Posix.sigset_t ();
                Posix.sigemptyset (sigset);
                //ret = Posix.select (fd + 1, &rdset, null, null, timeout);
                ret = Posix.pselect (fd + 1, &rdset, null, null, timeout, sigset);

                if (ret < 0) {
                    if (Posix.errno == Posix.EAGAIN) {
                        Cld.error ("Posix read error");
                    }
                } else if (ret == 0) {
                    stdout.printf ("%s hit timeout\n", id);
                } else if ((Posix.FD_ISSET (fd, rdset)) == 1) {
                    ret = (int)Posix.read (fd, buf, bufsz);
                    for (int i = 0; i < ret / 2; i++) {
                        total++;
if ((total % 32768) == 0) { stdout.printf ("%d: total read by %s: %d\n",Linux.gettid (), uri, 2 * total); }
                        lock (queue) {
                            queue.offer_head (buf [i]);
                        }
//                        stdout.printf ("%4X ", buf [i]);
//                        if ((total % num_chans) == 0) {
//                            stdout.printf ("\n");
//                        }
                    }
                }
            }

            Idle.add ((owned) callback);
            return 0;
        });

        yield;
    }

    /**
     * Write the queued data to the log.
     */
    private async void bg_process_data () throws ThreadError {
        SourceFunc callback = bg_process_data.callback;
        ushort datum = 0;
        int total = 0;
        Cld.LogEntry entry = new Cld.LogEntry ();

        GLib.Thread<int> thread = new GLib.Thread<int> ("bg_process_data", () => {
            while (active) {
                if (queue.size > num_chans) {

                    lock (queue) {
                        ec = db.exec ("BEGIN TRANSACTION", null, out errmsg);
                        for (int i = 0; i < (queue.size - (queue.size % num_chans)); i++) {
                            foreach (var column in objects.values) {
                                if (column is Cld.Column) {
                                    datum = queue.poll_tail ();
                                    entry.data.set ((column as Cld.Column).chref, (double)datum);
                                    total++;
if ((total % 32768) == 0) { stdout.printf ("%d: total dequed by %s: %d\n",Linux.gettid (), uri, 2 * total); }
                                    //stdout.printf ("%4X ", datum);
                                }
                            }
                            //stdout.printf ("\n");
                            entry.timestamp = entry.timestamp.add_seconds (0.00016);
                            log_entry_write (entry);
                        }
                        ec = db.exec ("END TRANSACTION", null, out errmsg);
                    }

                }
                Thread.usleep (100000);
            }

            Idle.add ((owned) callback);
            return 0;
        });

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
        string chan_uri = "";
        string desc = "";
        string tag = "";
        string type = "";
        string expression = "";
        string units = "";
        string query;

        foreach (var column in objects.values) {
            if (column is Cld.Column) {
                var channel = (column as Cld.Column).channel;
                chan_uri = "%s".printf (channel.uri.replace ("/", "_"));
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
                    chan_uri,
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
                    $CHAN_URI,
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

            parameter_index = stmt.bind_parameter_index ("$CHAN_URI");
            stmt.bind_text (parameter_index, chan_uri, -1, GLib.g_free);

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

    /**
     * Create the data log table and prepare a statement for inserting data.
     */
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
                                                    (column as Cld.Column).chref.replace ("/", "_"));
                ec = db.exec (query, null, out errmsg);
                if (ec != Sqlite.OK) {
                    stderr.printf ("Error: %s\n", errmsg);
                }
            }
        }

        query = """
            INSERT INTO %s
            (
            experiment_id,
            time,
        """.printf (_experiment_name);

        foreach (var column in objects.values) {
            if (column is Cld.Column) {
                query = "%s%s,".printf (query,
                    (column as Cld.Column).chref.replace ("/", "_"));
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

        ec = db.prepare_v2 (query, query.length, out log_stmt);
        if (ec != Sqlite.OK) {
            stderr.printf ("Error: %d: %s\n", db.errcode (), db.errmsg ());
        }
        parameter_index = log_stmt.bind_parameter_index ("$EXPERIMENT_ID");
        log_stmt.bind_int (parameter_index, experiment_id);
    }

    private void log_entry_write (Cld.LogEntry entry) {
        parameter_index = log_stmt.bind_parameter_index ("$TIME");
        log_stmt.bind_text (parameter_index, entry.time_as_string);

        int i = 0;
        double val = 0;
        foreach (var column in objects.values) {
            if (column is Cld.Column) {
                //parameter_index = log_stmt.bind_parameter_index ("$VAL%d".printf (i));
                /* Bind values to columns. The order of sequential access is consistent using this method */
                //log_stmt.bind_double (parameter_index, entry.data.get ((column as Cld.Column).chref));
                log_stmt.bind_double (i + 3, entry.data.get ((column as Cld.Column).chref));
                i++;
            }
        }
        log_stmt.step ();
       // log_stmt.clear_bindings ();
        log_stmt.reset ();
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

            /* Transfer data list to log entry */
            int i = 0;
            foreach (var column in objects.values) {
                if (column is Cld.Column) {
                    var uri = ((column as Cld.Column).channel as Cld.Object).uri;
                    ent.data.set (uri, data_list.get (i++));
                }
            }
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
            /* Wait for the queue to be empty */
            GLib.Timeout.add (100, deactivate_cb);
        }
    }

    private bool deactivate_cb () {
        if (queue.size == 0) {
            active = false;

            return false;
        } else {

            return false;
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
            ent.chan_uri = stmt.column_text (ChannelColumn.CHAN_URI);
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
            try {
                 backup_open ();
            } catch (Cld.FileError e) {
                if (e is Cld.FileError.ACCESS) {
                    Cld.error ("File access error: %s%s", path, file);
                    is_open = false;

                    return;
                } else {
                    is_open = true;
                }
            }
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
                            DateTime start,
                            DateTime stop,
                            int step) {
        string query;
        string name = "";
        string line = "";
        char sep = '\t';
        int count = 0;

        file_open (filename);
        for (int exp_id = exp_id_begin; exp_id <= exp_id_end; exp_id++) {
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
                Cld.debug ("Error: %d: %s\n", db.errcode (), db.errmsg ());
            }

            while (stmt.step () == Sqlite.ROW) {
                line = "%s\t".printf (stmt.column_text (ExperimentDataColumns.TIME));
                for (int column = 0; column < columns; column++) {
                    line += "%f%c".printf (stmt.column_double (column +
                                            ExperimentDataColumns.DATA0), sep);
                }
                line += "\n";
                if (count == 0) {
                    file_print (line);
                }
                count++;
                if (count == step) {
                    count = 0;
                }
            }
            stmt.reset ();
        }
        file_close ();
    }
}
