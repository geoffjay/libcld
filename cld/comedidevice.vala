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

using Comedi;
using Cld;

public class Cld.ComediDevice : Cld.AbstractDevice {
     /**
     * Default construction
     */
    public ComediDevice () {
        id = "dev0";
        hw_type = 0;
        driver = 0;
        name = "device";
        file = "/dev/comedi0";
        Comedi.Device (file);
    }
    /**
     * Construction using an xml node
     */
    public ComediDevice.from_xml_node (Xml.Node *node) {

        if (node->type == Xml.ElementType.ELEMENT_NODE &&
            node->type != Xml.ElementType.COMMENT_NODE) {
            id = node->get_prop ("id");
            var dt = node->get_prop ("driver");
            if (dt == "virtual")
                driver = DeviceType.VIRTUAL;
            else if (dt == "comedi")
                driver = DeviceType.COMEDI;
            else if (dt == "mcchid")
                driver = DeviceType.MCCHID;
            else if (dt == "advantech")
                driver = DeviceType.ADVANTECH;

            /* iterate through node children */
            for (Xml.Node *iter = node->children;
                 iter != null;
                 iter = iter->next) {
                if (iter->name == "property") {
                    switch (iter->get_prop ("name")) {
                        case "hardware":
                            name = iter->get_content ();
                            break;
                        case "file":
                            file = iter->get_content ();
                            break;
                        case "type":
                            var type = iter->get_content ();
                            if (type == "input")
                                hw_type = HardwareType.INPUT;
                            else if (type == "output")
                                hw_type = HardwareType.OUTPUT;
                            else if (type == "counter")
                                hw_type = HardwareType.COUNTER;
                            else if (type == "multifunction")
                                hw_type = HardwareType.MULTIFUNCTION;
                            break;
                        default:
                            break;
                    }
                }
            }
        }
        Comedi.Device (file);
    }
    public override string to_string () {
        string str_data = "[%s] : Device %s with file %s\n".printf (
                            id, name, file);
        /* add the hardware and driver types later */
        return str_data;
    }
    public override int close ();
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

    /**
     * {@inheritDoc}
     */
    public override string id { get; set; }

    /**
     * {@inheritDoc}
     */
    public override int hw_type { get; set; }

    /**
     * {@inheritDoc}
     */
    public override int driver { get; set; }

    /**
     * {@inheritDoc}
     */
    public override string description { get; set; }

    /**
     * {@inheritDoc}
     */
    public override string filename { get; set; }

    /**
     * {@inheritDoc}
     */
    public override int unix_fd { get; set; }


    private bool _is_open;
    public bool is_open {
        get { return _is_open; }
        set { _is_open = value; }
    }

    /**
     * The comedi specific hardware device that this class will use.
     */
    protected Comedi.Device device;
    private bool _is_open;
    public bool is_open { get; }


    private Comedi.InstructionList instruction_list;
    private Gee.Map<string, Object> ai_channels;
    private Gee.Map<string, Object> ao_channels;
    private const int NSAMPLES = 10; //XXX Why is this set to 10 (Steve)??
    private int ai_subdevice;
    private int ao_subdevice;
    /**
     * Default construction
     */
    public ComediDevice () {
        objects = new Gee.TreeMap<string, Object> ();
        id = "dev0";
        hw_type = HardwareType.INPUT;
        driver = DeviceType.COMEDI;
        filename = "/dev/comedi0";
    }

    /**
     * Construction using an xml node
     */
    public ComediDevice.from_xml_node (Xml.Node *node) {
        objects = new Gee.TreeMap<string, Object> ();
        if (node->type == Xml.ElementType.ELEMENT_NODE &&
            node->type != Xml.ElementType.COMMENT_NODE) {
            id = node->get_prop ("id");

            /* iterate through node children */
            for (Xml.Node *iter = node->children;
                 iter != null;
                 iter = iter->next) {
                if (iter->name == "property") {
                    switch (iter->get_prop ("name")) {
                        case "filename":
                            filename = iter->get_content ();
                            break;
                        case "type":
                            var type = iter->get_content ();
                            if (type == "input")
                                hw_type = HardwareType.INPUT;
                            else if (type == "output")
                                hw_type = HardwareType.OUTPUT;
                            else if (type == "counter")
                                hw_type = HardwareType.COUNTER;
                            else if (type == "multifunction")
                                hw_type = HardwareType.MULTIFUNCTION;
                            break;
                        default:
                            break;
                    }
                }
                else if (iter->name == "object") {
                    switch (iter->get_prop ("type")) {
                        case "task":
                            var task = new ComediTask.from_xml_node (iter);
                            add (task as Cld.Object);
                            break;
                        default:
                            break;
                    }
                }
            }
        }
    }

    /**
     * {@inheritDoc}
     */
    public override bool open () {
        dev = new Comedi.Device (filename);
        if (dev != null) {
            _is_open = true;
            return true;
        }
        else {
            _is_open = false;
            return false;
        }
    }

    /**
     * {@inheritDoc}
     */
    public override bool close () {
        if (dev.close () == 0) {
            _is_open = false;
            return true;
        }
        else
            return false;
    }


    /**
     * Retrieve information about the Comedi device.
     */
    public Information info () {
        var i = new Information ();
        i.id = id;
        i.version_code = dev.get_version_code ();
        i.driver_name = dev.get_driver_name ();
        i.board_name = dev.get_board_name ();
        i.n_subdevices = dev.get_n_subdevices ();

        return i;
    }

    /**
     * {@inheritDoc}
     */
    public override void update_objects (Gee.Map<string, Object> val) {
        _objects = val;
    }

    /**
     * {@inheritDoc}
     */
    public override void add (Object object) {
        objects.set (object.id, object);
    }

    /**
     * {@inheritDoc}
     */
    public override Object? get_object (string id) {
        Object? result = null;

        if (objects.has_key (id)) {
            result = objects.get (id);
        } else {
            foreach (var object in objects.values) {
                if (object is Container) {
                    result = (object as Container).get_object (id);
                    if (result != null) {
                        break;
                    }
                }
            }
        }

        return result;
    }


    public override string to_string () {
        string str_data = "[%s] : Comedi device using file %s\n".printf (
                            id, filename);
        /* add the hardware and driver types later */
        if (!objects.is_empty) {
            foreach (var subdev in objects.values) {
                str_data += "    %s".printf (subdev.to_string ());
            }
        }

        return str_data;
    }

    /**
     * Comedi device information class.
     */
    public class Information {

        /**
         * {@inheritDoc}
         */
        public string id { get; set; }

        public int version_code { get; set; }
        public string driver_name { get; set; }
        public string board_name { get; set; }
        public int n_subdevices { get; set; }

        public Information () {
            id = "XXXX";
            version_code = -1;
            driver_name = "XXXX";
            board_name = "XXXX";
            n_subdevices = -1;
        }

        /**
         * {@inheritDoc}
         */
        public string to_string () {
            string str_data = ("[%s] : Information for this Comedi device:\n" +
                                "   version code: %d\n" +
                                "   driver name: %s\n" +
                                "   board name: %s\n" +
                                "   n_subdevices: %d\n").printf (
                                    id, version_code, driver_name, board_name, n_subdevices);
            return str_data;
        }
    }
}

