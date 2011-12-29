/*
 * comedi.vapi
 * Vala bindings for the control and measurement devices library comedi
 * Copyright (c) 2011 Geoff Johnson <geoff.jay@gmail.com>
 * License: GNU LGPL v3 as published by the Free Software Foundation
 *
 * This binding is a (mostly) strict binding to the function-oriented
 * nature of this C library.
 * - more of a placeholder for now as I work on it
 */

[CCode (cprefix = "comedi_", cheader_filename = "comedilib.h")]
namespace Comedi {

    /* -- comedi.h -- */

    [CCode(cname = "int", cprefix = "COMEDI_DEVCONF_AUX_")]
    public enum DevConfAux {
        DATA3_LENGTH,
        DATA2_LENGTH,
        DATA1_LENGTH,
        DATA0_LENGTH,
        DATA_HI,
        DATA_LO,
        DATA_LENGTH
    }

    [CCode (cname = "CR_PACK")]
    public static int pack (int chan, int rng, int aref);

    [CCode (cname = "CR_PACK_FLAGS")]
    public static int pack_flags (int chan, int range, int aref, int flags);

    [CCode (cname = "CR_CHAN")]
    public static int chan (int a);

    [CCode (cname = "CR_RANGE")]
    public static int range (int a);

    [CCode (cname = "CR_AREF")]
    public static int aref (int a);

    /*
     * Analog Reference Options
     */
    [CCode (cname = "int", cprefix = "AREF_")]
    public enum ARef {
        GROUND,
        COMMON,
        DIFF,
        OTHER
    }

    /*
     * Counters
     */
    [CCode (cname = "int", cprefix = "GPCT_")]
    public enum Gpct {
        RESET,
        SET_SOURCE,
        SET_GATE,
        SET_DIRECTION,
        SET_OPERATION,
        ARM,
        DISARM,
        GET_INT_CLK_FRQ,
        INT_CLOCK,
        EXT_PIN,
        NO_GATE,
        UP,
        DOWN,
        HWUD,
        SIMPLE_EVENT,
        SINGLE_PERIOD,
        SINGLE_PW,
        CONT_PULSE_OUT,
        SINGLE_PULSE_OUT
    }

    /*
     * Instructions
     */
    [CCode (cname = "int", cprefix = "INSN_MASK_")]
    public enum InsnMask {
        WRITE,
        READ,
        SPECIAL
    }

    [CCode (cname = "int", cprefix = "INSN_")]
    public enum Insn {
        READ,
        WRITE,
        BITS,
        CONFIG,
        GTOD,
        WAIT,
        INTTRIG
    }

    /*
     * Range Stuff
     */
    [CCode (cname = "__RANGE")]
    public static int __range (int a, int b);

    [CCode (cname = "RANGE_OFFSET")]
    public static int range_offset (int a);

    [CCode (cname = "RANGE_LENGTH")]
    public static int range_length (int b);

    [CCode (cname = "RF_UNIT")]
    public static int rf_unit (int flags);

    [CCode (cname = "int", cprefix = "UNIT_")]
    public enum Unit {
        volt,
        mA,
        none
    }

    /*
     * Callback Stuff
     */
    [CCode (cname = "int", cprefix = "COMEDI_CB_")]
    public enum Callback {
        EOS,
        EOA,
        BLOCK,
        EOBUF,
        ERROR,
        OVERFLOW
    }

// ???
//    [SimpleType]
//    [GIR (name = "lsampl_t")]
//    [CCode (cname = "unsigned int")]

// ???
//    [SimpleType]
//    [GIR (name = "sampl_t")]
//    [CCode (cname = "unsigned short")]

    /* -- comedilib.h -- */

    /*
     * Macros
     */
    [CCode (cprefix = "COMEDI_VERSION_CODE")]
    public static int version_code (int a, int b, int c);

    [CCode (cname = "int", cprefix = "COMEDI_OOR_")]
    public enum OOR_Behavior {
        NUMBER,
        NAN
    }

    [CCode (cname = "struct comedi_range")]
    public struct Range {
        [CCode (cname = "min")]
        public double min;

        [CCode (cname = "max")]
        public double max;

        [CCode (cname = "unit")]
        public uint unit;
    }

    [CCode (cname = "struct comedi_sv_t")]
    public struct Sv {
        [CCode (cname = "dev")]
        public Device dev;

        [CCode (cname = "subdevice")]
        public uint subdevice;

        [CCode (cname = "chan")]
        public uint chan;

        [CCode (cname = "range")]
        public int range;

        [CCode (cname = "aref")]
        public int aref;

        [CCode (cname = "n")]
        public int n;

        [CCode (cname = "maxdata")]
        public Sample maxdata;
    }

    /*
     * Logging
     */
    [CCode (cname = "comedi_loglevel")]
    public static int loglevel (int loglevel);

    [CCode (cname = "comedi_perror")]
    public static void perror (string s);

    [CCode (cname = "comedi_strerror")]
    public static string strerror (int errnum);

    [CCode (cname = "comedi_errno")]
    public static int errno (int loglevel);

    [CCode (cname = "comedi_fileno")]
    public static int fileno (Device dev);

    /*
     * Global behavior
     */
    [CCode (cname = "comedi_set_global_oor_behavior")]
    public static OOR_Behavior set_global_oor_behavior (OOR_Behavior oor);

    /*
     * Device
     */
    [Compact]
    public class Device {
        [CCode (cname = "comedi_open")]
        public int open (string fn);

        [CCode (cname = "comedi_close")]
        public int close ();

        /* device queries */
        [CCode (cname = "comedi_get_n_subdevices")]
        public int get_n_subdevices ();

        [CCode (cname = "comedi_get_version_code")]
        public int get_version_code ();

        [CCode (cname = "comedi_get_driver_name")]
        public string get_driver_name ();

        [CCode (cname = "comedi_get_board_name")]
        public string get_board_name ();

        [CCode (cname = "comedi_get_read_subdevice")]
        public int get_read_subdevice ();

        [CCode (cname = "comedi_get_write_subdevice")]
        public int get_write_subdevice ();

        /* subdevice queries */

        /* channel queries */

        /* buffer queries */

        /* low-level */

        /* syncronous */

        /* slow varying */

        /* streaming I/O (commands) */

        /* buffer control */
    }
}
