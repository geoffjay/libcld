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

    /**
     * The comedi specific hardware device that this class will use.
     */
    protected Comedi.Device device;
//    protected Comedi.InstructionList instruction_list;
//    protected Comedi.Instruction instruction;
    private bool _is_open;
    public bool is_open {
        get { return _is_open; }
        set { _is_open = value; }
    }

    /**
     * Default construction
     */
    public ComediDevice () {
        id = "dev0";
        hw_type = HardwareType.INPUT;
        driver = DeviceType.COMEDI;
        filename = "/dev/comedi0";
    }

    /**
     * Construction using an xml node
     */
    public ComediDevice.from_xml_node (Xml.Node *node) {

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
        int n = 0;
        const int NSAMPLES = 10; //XXX Why is this set to 10 (Steve)??
        const int MAX_SAMPLES = 128;
//        instruction_list.n_insns = channels.size;
//        foreach (var channel in channels.values) {
//            instruction.insn = InstructionAttribute.READ;
//            instruction.n    = NSAMPLES;
//            instruction.data = null;
//            instruction.subdev = subdevice;
//            instruction.chanspec = pack (n, (channel as AIChannel).
//                                        range, AnalogReference.GROUND);
//            n++;
//        }
//        instruction_list.insns = insns;
    }

    /**
     * This is just a test function used for debugging only.
     **/
    public void test () {
        uint data[1];
        device.data_read (0, 0, 4, AnalogReference.GROUND, data);
        message ("data: %u", data[0]);
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

    public override string to_string () {
        string str_data = "[%s] : Comedi device using file %s\n".printf (
                            id, filename);
        /* add the hardware and driver types later */
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
