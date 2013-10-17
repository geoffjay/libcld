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
     * Property backing fields.
     */
    private Gee.Map<string, Object> _objects;

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
                        case "subdevice":
                            var subdev = new ComediSubDevice.from_xml_node (iter);
                            add (subdev as Cld.Object);
                            break;
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
        device = new Comedi.Device (filename);
        if (device != null) {
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
        if (device.close () == 0) {
            _is_open = false;
            return true;
        }
        else
            return false;
    }




    /**
     * Build a Comedi instruction list for a single subdevice
     * from a list of channels.
     **/
    public void set_insn_list (Gee.Map<string, Object> channels, int subdevice) {
        ai_channels = channels;
        ai_subdevice = subdevice;
        Instruction[] instructions = new Instruction [ai_channels.size];
        int n = 0;
        instruction_list.n_insns = channels.size;
        foreach (var channel in channels.values) {
            instructions[n] = Instruction ();
            instructions[n].insn = InstructionAttribute.READ;
            instructions[n].n    = NSAMPLES;
            instructions[n].data = new uint [NSAMPLES];
            instructions[n].subdev = subdevice;
            instructions[n].chanspec = pack (n, (channel as AIChannel).
                                        range, AnalogReference.GROUND);
            n++;
        }
        instruction_list.insns = instructions;
    }

    public void set_out_channels (Gee.Map<string, Object> channels, int subdevice) {
        ao_channels = channels;
        ao_subdevice = subdevice;
    }

    /**
     * This method executes a Comedi Instruction list.
     */
    public void execute_instruction_list () {
        Comedi.Range range;
        uint maxdata;
        int ret, i, j;
        double meas;

        ret = device.do_insnlist (instruction_list);
        if (ret < 0)
            perror ("do_insnlist failed:");
        i = 0;
        foreach (var channel in ai_channels.values) {
            meas = 0.0;
            maxdata = device.get_maxdata (ai_subdevice, (channel as AIChannel).num);
            for (j = 0; j < NSAMPLES; j++) {
                range = device.get_range (ai_subdevice, (channel as AIChannel).num, (channel as AIChannel).range);
                //message ("range min: %.3f, range max: %.3f, units: %u", range.min, range.max, range.unit);
                meas += Comedi.to_phys (instruction_list.insns[i].data[j], range, maxdata);
                //message ("instruction_list.insns[%d].data[%d]: %u, physical value: %.3f", i, j, instruction_list.insns[i].data[j], meas/(j+1));
            }
            meas = meas / (j);
            (channel as AIChannel).add_raw_value (meas);
//            Cld.debug ("Channel: %s, Raw value: %.3f\n", (channel as AIChannel).id, (channel as AIChannel).raw_value);
            i++;
        }
     }

     public void execute_polled_output () {
        Comedi.Range range;
        uint maxdata,  data;
        double val;
        foreach (var channel in ao_channels.values) {
            val = (channel as AOChannel).scaled_value;
            range = device.get_range (ao_subdevice, (channel as AOChannel).num, (channel as AOChannel).range);
            maxdata = device.get_maxdata (ao_subdevice, (channel as AOChannel).num);
            data = (uint)((val / 100.0) * maxdata);
           // message ("%s scaled_value: %.3f, data: %u", (channel as AOChannel).id, (channel as AOChannel).scaled_value, data);
            device.data_write (ao_subdevice, (channel as AOChannel).num, (channel as AOChannel).range, AnalogReference.GROUND, data);
        }
     }

    /**
     * Retrieve information about the Comedi device.
     */
    public Information info () {
        var i = new Information ();
        i.id = id;
        i.version_code = device.get_version_code ();
        i.driver_name = device.get_driver_name ();
        i.board_name = device.get_board_name ();
        i.n_subdevices = device.get_n_subdevices ();

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
