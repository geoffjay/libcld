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
        NULL_REF,
        KEY_EXISTS
    }

    public errordomain FileError {
        ACCESS
    }

    public errordomain ConfigurationError {
        EMPTY_NODESET,
        INVALID_CONFIGURATION
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
    private static int verbosity = 3;

    /**
     * Library initialization.
     */
    public void init () { }

    /**
     * Logging facilities.
     */

    public void increase_log_level () {
        verbosity = (verbosity == 3) ? verbosity : verbosity++;
    }

    public void decrease_log_level () {
        verbosity = (verbosity == 0) ? verbosity : verbosity--;
    }

#if USE_COMEDI

    namespace Comedi {

        public static Comedi.Polynomial calibration_to_polynomial (Cld.Calibration calibration) {
            /* Future for comedi_to_physical replacement in Comedi.Task ??? */
        }
    }

#endif
}
