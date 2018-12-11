/**
 * libcld
 * Copyright (c) 2015, Geoff Johnson, All rights reserved.
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 3.0 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library.
 */

/**
 * A common interface for log type objects.
 */
[GenericAccessors]
public interface Cld.Log : Cld.Object {

    /**
     * Possible options to flag when the log file is time stamped.
     */
    public enum TimeStampFlag {
        NEVER,
        OPEN,
        CLOSE,
        BOTH;

        public string to_string () {
            switch (this) {
                case NEVER: return "never";
                case OPEN:  return "open";
                case CLOSE: return "close";
                case BOTH:  return "both";
                default: assert_not_reached ();
            }
        }

        public string description () {
            switch (this) {
                case NEVER: return "Never time stamp";
                case OPEN:  return "Time stamp on open";
                case CLOSE: return "Time stamp on close";
                case BOTH:  return "Time stamp on open and close";
                default: assert_not_reached ();
            }
        }

        public static TimeStampFlag[] all () {
            return {
                NEVER,
                OPEN,
                CLOSE,
                BOTH
            };
        }

        public static TimeStampFlag parse (string value) {
            try {
                var regex_never = new Regex ("never", RegexCompileFlags.CASELESS);
                var regex_open = new Regex ("open", RegexCompileFlags.CASELESS);
                var regex_close = new Regex ("close", RegexCompileFlags.CASELESS);
                var regex_both = new Regex ("both", RegexCompileFlags.CASELESS);

                if (regex_never.match (value)) {
                    return NEVER;
                } else if (regex_open.match (value)) {
                    return OPEN;
                } else if (regex_close.match (value)) {
                    return CLOSE;
                } else if (regex_both.match (value)) {
                    return BOTH;
                } else {
                    return NEVER;
                }
            } catch (RegexError e) {
                message ("TimeStampFlag regex error: %s", e.message);
            }

            return NEVER;
        }
    }

    /**
     * The name of the log file.
     */
    public abstract string name { get; set; }

    /**
     * File system path to write the log file or database file to.
     */
    //protected abstract string path { get; set; }

    /**
     * Base file name to use for the log file or database file.
     */
    //protected abstract string file { get; set; }

    /**
     * The log file
     */
    public abstract GLib.File gfile { get; set; }

    /**
     * The log file rate in Hz.
     */
    public abstract double rate { get; set; }

    /**
     * Whether or not the log file is currently active.
     */
    public abstract bool active { get; set; }

    /**
     * Flag to check whether the file is open or not.
     */
    public abstract bool is_open { get; set; }

    /**
     * Date/Time format to use when renaming the file or database table.
     */
    public abstract string date_format { get; set; }

    /**
     * A list of FIFOs for inter-process data transfer.
     * The data are paired a pipe name and file descriptor.
     */
    protected abstract Gee.Map<string, int>? fifos { get; set; }

    /**
     * The source of the channel value information.
     * fifo: The data comes from a named pipe.
     * channel: The data comes from reading the value directly from the channel
     */
    public abstract string data_source { get; set; }

    /**
     * Request the uri of an IPC (eg. named pipe, 0MQ socket)
     *
     **/
    public abstract signal void request ();

    /**
     * Connect the columns to their corresponding channel signals.
     */
    public abstract void connect_signals ();

    /**
     * Connect to a multiplexer for streamin acquisition.
     */
    public abstract void connect_data_source ();

    /**
     * Start the log file output as an async method.
     */
    public abstract void start ();

    /**
     * Stop a log that is executing.
     */
    public abstract void stop ();

    /**
     * @return a message containing the state of key parameters
     */
    public abstract string status ();
}
