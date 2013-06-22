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
 * Authors:
 *  Geoff Johnson <geoff.jay@gmail.com>
 *  Steve Roy <sroy1966@gmail.com>
 */

/**
 */
public class Cld.ComediDevice : Cld.AbstractDevice {
        public Device (string fn);

        public int close ();
        public int get_n_subdevices ();
        public int get_version_code ();
        public unowned string get_driver_name ();
        public unowned string get_board_name ();
        public int get_read_subdevice ();
        public int get_write_subdevice ();
        public int fileno ();

        /* subdevice queries */
        public int get_subdevice_type (uint subdevice);
        public int find_subdevice_by_type (int type, uint subd);
        public int get_subdevice_flags (uint subdevice);
        public int get_n_channels (uint subdevice);
        public int range_is_chan_specific (uint subdevice);
        public int maxdata_is_chan_specific (uint subdevice);

        /* channel queries */
        public uint get_maxdata (uint subdevice, uint chan);
        public int get_n_ranges (uint subdevice, uint chan);
        public Range get_range (uint subdevice, uint chan, uint range);
        public int find_range (uint subd, uint chan, uint unit, double min, double max);

        /* buffer queries */
        public int get_buffer_size (uint subdevice);
        public int get_max_buffer_size (uint subdevice);
        public int set_buffer_size (uint subdevice, uint len);

        /* low-level */
        public int do_insnlist (InstructionList il);
        public int do_insn (Instruction insn);
        public int lock (uint subdevice);
        public int unlock (uint subdevice);

        /* syncronous */
        public int data_read (uint subd, uint chan, uint range, uint aref, [CCode (array_length = false)] uint[] data);
        public int data_read_n (uint subd, uint chan, uint range, uint aref, [CCode (array_length = false)] uint[] data, uint n);
        public int data_read_hint (uint subd, uint chan, uint range, uint aref);
        public int data_read_delayed (uint subd, uint chan, uint range, uint aref, [CCode (array_length = false)] uint[] data, uint nano_sec);
        public int data_write (uint subd, uint chan, uint range, uint aref, uint data);
        public int dio_config (uint subd, uint chan, uint dir);
        public int dio_get_config (uint subd, uint chan, [CCode (array_length = false)] uint[] dir);
        public int dio_read (uint subd, uint chan, [CCode (array_length = false)] uint[] bit);
        public int dio_write (uint subd, uint chan, uint bit);
        public int dio_bitfield2 (uint subd, uint write_mask, [CCode (array_length = false)] uint[] bits, uint base_channel);
        public int dio_bitfield (uint subd, uint write_mask, [CCode (array_length = false)] uint[] bits);

        /* streaming I/O (commands) */
        public int get_cmd_src_mask (uint subdevice, Command cmd);
        public int get_cmd_generic_timed (uint subdevice, out Command cmd, uint chanlist_len, uint scan_period_ns);
        public int cancel (uint subdevice);
        public int command (Command cmd);
        public int command_test (Command cmd);
        public int poll (uint subdevice);

        /* buffer control */
        public int set_max_buffer_size (uint subdev, uint max_size);
        public int get_buffer_contents (uint subdev);
        public int mark_buffer_read (uint subdev, uint bytes);
        public int mark_buffer_written (uint subdev, uint bytes);
        public int get_buffer_offset (uint subdev);
    }

}

