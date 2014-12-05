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
 * Skeletal implementation of the {@link Log} interface.
 */
public abstract class Cld.AbstractLog : Cld.AbstractContainer, Cld.Log {

    /**
     * {@inheritDoc}
     */
    public virtual string name { get; set; }

    /**
     * {@inheritDoc}
     */
    public virtual string path { get; set; }

    /**
     * {@inheritDoc}
     */
    public virtual string file { get; set; }

    /**
     * {@inheritDoc}
     */
    public virtual double rate { get; set; }

    /**
     * {@inheritDoc}
     */
    public virtual int dt { get { return (int)(1e3 / rate); } }

    /**
     * {@inheritDoc}
     */
    public virtual bool active { get; set; }

    /**
     * {@inheritDoc}
     */
    public virtual bool is_open { get; set; }

    /**
     * {@inheritDoc}
     */
    public virtual string date_format { get; set; }

    /**
     * {@inheritDoc}
     */
    public virtual Gee.Map<string, int>? fifos { get; set; }

    /**
     * A double ended queue for raw data.
     */
    protected virtual Gee.Deque<ushort> raw_queue { get; set; }

    /**
     * DateTime data to use for time stamping log file.
     */
    protected DateTime start_time;

    /**
     * A double ended queue for LogEntries.
     */
    protected virtual Gee.Deque<Cld.LogEntry> entry_queue { get; set; }

    /**
     * The total number of channels in this log.
     */
    protected int nchans { get; set; }

    construct {
        fifos = new Gee.TreeMap<string, int> ();
        raw_queue = new Gee.LinkedList<ushort> ();
        entry_queue = new Gee.LinkedList<Cld.LogEntry> ();
    }

    /**
     * {@inheritDoc}
     */
    public abstract void start ();

    /**
     * {@inheritDoc}
     */
    public abstract void stop ();

    /**
     * {@inheritDoc}
     */
    public virtual void connect_signals () {
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
     * Write a single entry to the log
     */
    protected abstract void log_entry_write (Cld.LogEntry entry);

    /**
     * Write all the entry queue values to the log
     */
    protected abstract void process_entry_queue ();

    /**
     * Launches a thread that pulls a rows of data from a named pipe and writes
     * it the  raw queue.
     */
    protected async void bg_fifo_watch (int fd) throws ThreadError {
        SourceFunc callback = bg_fifo_watch.callback;
        int ret = -1;
        int bufsz = 1048576;
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
                timeout.tv_nsec = 100000000;
                Posix.sigset_t sigset = new Posix.sigset_t ();
                Posix.sigemptyset (sigset);
                //ret = Posix.select (fd + 1, &rdset, null, null, timeout);
                ret = Posix.pselect (fd + 1, &rdset, null, null, timeout, sigset);

                if (ret < 0) {
                    if (Posix.errno == Posix.EAGAIN) {
                        error ("Posix pselect error EAGAIN");
                    }
                } else if (ret == 0) {
                    stdout.printf ("%s hit timeout\n", id);
                } else if ((Posix.FD_ISSET (fd, rdset)) == 1) {
                    ret = (int)Posix.read (fd, buf, bufsz);
                    if (ret == -1) {
                        error ("Posix.errno = %d", Posix.errno);
                    }
                    lock (raw_queue) {
                        for (int i = 0; i < ret / 2; i++) {
                            total++;
//if ((total % 32768) == 0) { stdout.printf ("%d: total read by %s: %d\n",Linux.gettid (), uri, total); }
                            (raw_queue as Gee.Deque<ushort>).offer_head (buf [i]);
//                        stdout.printf ("%4X ", buf [i]);
//                        if ((total % nchans) == 0) {
//                            stdout.printf ("\n");
//                        }
                        }
                    }
                }
            }

            Idle.add ((owned) callback);

            return 0;
        });

        yield;
    }

    /**
     * Launches a thread that reads Cld.Channel values and writes them to the data queue.
     */
    protected async void bg_channel_watch () throws ThreadError {
        SourceFunc callback = bg_channel_watch.callback;
        int64 start_time_mono = GLib.get_monotonic_time ();
        int64 count = 1;

        int total = 0;

        GLib.Thread<int> thread = new GLib.Thread<int> ("bg_channel_watch", () => {
            Mutex mutex = new Mutex ();
            Cond cond = new Cond ();
            int64 end_time;

            while (active) {
                Cld.LogEntry entry = new Cld.LogEntry ();
                entry.data = new double [nchans];
                entry.timestamp = new GLib.DateTime.now_local ();
                entry.time_us = entry.timestamp.difference (start_time);

                int i = 0;
                foreach (var column in objects.values) {
                    if (column is Cld.Column) {
                        entry.data [i++] = (column as Cld.Column).channel_value;
                    }
                }

                lock (entry_queue) {
                    entry_queue.offer_head (entry);
                }

                mutex.lock ();
                try {
                    end_time = start_time_mono + count++ * (1000 / (int)rate) * TimeSpan.MILLISECOND;
                    while (cond.wait_until (mutex, end_time))
                        ; /* do nothing */
                } finally {
                    mutex.unlock ();
                }

            }

            Idle.add ((owned) callback);

            return 0;
        });

        yield;
    }

    /**
     * Launches a thread that reads from the raw data queue and writes to a log entry queue.
     */
    protected async void bg_raw_process () throws ThreadError {
        SourceFunc callback = bg_raw_process.callback;
        ushort datum = 0;
        int total = 0;
        int nscans = 0;

        GLib.Thread<int> thread = new GLib.Thread<int> ("bg_process_raw", () => {
            while (active) {
                lock (raw_queue) {
                    lock (entry_queue) {

                        if (raw_queue.size > nchans) {
                            nscans = raw_queue.size / nchans;

                            for (int i = 0; i < nscans; i++) {
                                Cld.LogEntry entry = new Cld.LogEntry ();
                                entry.data = new double [nchans];
                                entry.timestamp = entry.timestamp.add_seconds (0.00016);

                                for (int j = 0; j < nchans; j++) {
                                        datum = raw_queue.poll_tail ();
                                        entry.data [j] = (double) datum;
                                        total++;
//if ((total % 32768) == 0) { stdout.printf ("%d: total raw dequed: %d  qsize: %d\n",Linux.gettid (), total, raw_queue.size); }
                                }

                                entry_queue.offer_head (entry);
                            }
                        }
                    }
                }
                Thread.usleep (10000);
            }

            Idle.add ((owned) callback);
            return 0;
        });

        yield;
    }

    /**
     * Launches a thread that takes log entries from a queue and writes them to the log.
     */
    protected async void bg_entry_write () {
        SourceFunc callback = bg_entry_write.callback;
        int total = 0;
        int qmin = 0;
        //int maxqmin = 1600;
        //int minqmin = 400;
        //int diff = 0;
        GLib.Thread<int> thread = new GLib.Thread<int> ("bg_entry_write", () => {
            while (active) {
                if (entry_queue.size > qmin) {
                    lock (entry_queue) {
                        process_entry_queue ();
                        total += entry_queue.size * nchans;
//stdout.printf ("%d: entry queue size after: %d qmin: %d\n", Linux.gettid (), entry_queue.size, qmin);
                        /* Use this to optimize queue_size */
                        //diff = entry_queue.size - qmin;
                        //diff > 0 ? qmin+= 10 : qmin-= 10;
                        //qmin > maxqmin ? qmin = maxqmin : qmin = qmin;
                        //qmin > minqmin ? qmin = qmin : qmin = minqmin;
                    }
                }

               Thread.usleep (10000);
            }

            Idle.add ((owned) callback);

            return 0;
        });
        yield;
    }
}
