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
                //Cld.message ("TimeStampFlag regex error: %s", e.message);
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
    public abstract string path { get; set; }

    /**
     * Base file name to use for the log file or database file.
     */
    public abstract string file { get; set; }

    /**
     * The log file rate in Hz.
     */
    public abstract double rate { get; set; }

    /**
     * Time between iterations in milliseconds.
     */
    public abstract int dt { get { return (int)(1e3 / rate); } }

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
     * An entry representing a row of data.
     */
    public abstract Cld.LogEntry entry { get; set; }

    /**
     * Start the log file output as an async method.
     */
    public abstract void start ();

    /**
     * Stop a log that is executing.
     */
    public abstract void stop ();
}
