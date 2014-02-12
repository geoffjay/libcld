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

using Config;

/**
 * Control Logging and Data Acquisition library
 */
namespace Cld {

    public errordomain CalibrationError {
        KEY_NOT_FOUND
    }

    /**
     * A general error domain.
     */
    public errordomain Error {
        NULL_REF
    }

    /**
     * Future plan is to incorporate more device-specific setup and features
     * including information about the hardware, eg. bit count of a DAC or
     * maximum sampling rate of an ADC.
     */

    public enum DeviceType {
        VIRTUAL = 0,
        COMEDI,
        MCCHID,
        ADVANTECH,
        ARDUINO,
        EMBARM,
        BEAGLEBOARD,
        PANDABOARD;

        public string to_string () {
            switch (this) {
                case VIRTUAL:     return "Virtual";
                case COMEDI:      return "Comedi";
                case MCCHID:      return "Measurement Computing";
                case ADVANTECH:   return "Advantech";
                case ARDUINO:     return "Arduino";
                case EMBARM:      return "Technologic Systems";
                case BEAGLEBOARD: return "BeagleBoard";
                case PANDABOARD:  return "PandaBoard";
                default:          assert_not_reached ();
            }
        }
    }

    /**
     * Possibly useless. Used once as indication for determining hardware that
     * was in a system.
     */

    public enum HardwareType {
        INPUT = 0,
        OUTPUT,
        COUNTER,
        MULTIFUNCTION;

        public string to_string () {
            switch (this) {
                case INPUT:         return "Input";
                case OUTPUT:        return "Output";
                case COUNTER:       return "Counter";
                case MULTIFUNCTION: return "Multi-function";
                default:            assert_not_reached ();
            }
        }
    }

    /**
     * Internal variables used for library control... possibly.
     * XXX seems strange to do option parsing in a library, maybe rethink this
     */
    private static int verbosity = 2;

    /*
     *private const OptionEntry[] options = {{
     *    "log-level", 0, 0, OptionArg.INT, ref verbosity,
     *    "Control the log level verbosity.", null
     *},{
     *    null
     *}};
     */

    /**
     * Library initialization.
     */
    public void init (string[] args) {

        /*
         *try {
         *    var opt_context = new OptionContext (PACKAGE_NAME);
         *    opt_context.set_help_enabled (false);
         *    opt_context.add_main_entries (options, null);
         *    opt_context.parse (ref args);
         *} catch (OptionError e) {
         *    Cld.error ("OptionsError %s", e.message);
         *}
         */
    }

    /**
     * Logging facilities.
     */

    public void error (string format, ...) {
        var list = va_list();
        string res = "libcld [ERROR] %s\n".printf (format.vprintf (list));
        stderr.puts (res);
    }

    public void message (string format, ...) {
        if (verbosity >= 1) {
            var list = va_list();
            string res = "libcld [MSG] %s\n".printf (format.vprintf (list));
            stdout.puts (res);
        }
    }

    public void debug (string format, ...) {
        if (verbosity >= 2) {
            var list = va_list();
            string res = "libcld [DEBUG] %s\n".printf (format.vprintf (list));
            stdout.puts (res);
        }
    }
}
