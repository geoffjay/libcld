/*
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
 *  Stephen Roy <sroy1966@gmail.com>
 */

/**
 * Brabender ISC-CM Plus implementing TCP/IP Modbus
 *
 * XXX should be a container.
 * XXX should be buildable using XML.
 */
public class Cld.BrabenderModule : AbstractModule {
    int timeout_ms = 100;

    /**
     * Operating Mode.
     */
    public enum Mode {
        FREE0,
        GF,
        VR,
        VS,
        DI,
        CM,
        GD,
        VF,
        FREE1,
        AT,
        FREE2,
        GM,
        BF,
        BM,
        FREE3,
        FREE4;

        public string to_string () {
            switch (this) {
                case FREE0: return "Free(0)";
                case GF:    return "Gravimetric Feed";
                case VR:    return "Volumetric Regulation";
                case VS:    return "Volumetric Setting";
                case DI:    return "Discharge";
                case CM:    return "Check max. output";
                case GD:    return "Gravimetric Discharge";
                case VF:    return "Volumetric Feeding";
                case FREE1: return "Free(1)";
                case AT:    return "Auto-tare";
                case FREE2: return "Free(2)";
                case GM:    return "Gravimetric Measuring";
                case BF:    return "Batch Feeding";
                case BM:    return "Batch Measuring";
                case FREE3: return "Free(3)";
                case FREE4: return "Free(4)";
                default:    return "default";
            }
        }
    }

    /**
     * {@inheritDoc}
     */
    public override string id { get; set; }

    public override bool loaded { get; set; default = false; }

    /**
     * The port to connect to the Brabender with.
     */
    public Port port { get; set; }

    public Gee.Map<string, Object> channels { get; set; }

    /**
     * The operating mode.
     */
    public Mode mode { get; set; default = Mode.GF; }


    /**
     * Default construction.
     */
    public BrabenderModule () {
        uint source_id = Timeout.add (timeout_ms, new_data_cb);
        }


    /**
     * Full construction using available settings.
     */
    public BrabenderModule.full (string id, Port port) {
        this.id = id;
        this.port = port;
        uint source_id = Timeout.add (timeout_ms, new_data_cb);
    }

    /**
     * Alternate construction that uses an XML node to populate the settings.
     */

//    public BrabenderModule.from_xml_node (Xml.Node *node) {
//
//        if (node->type == Xml.ElementType.ELEMENT_NODE &&
//            node->type != Xml.ElementType.COMMENT_NODE) {
//            id = node->get_prop ("id");
//            /* iterate through node children */
//            for (Xml.Node *iter = node->children;
//                 iter != null;
//                 iter = iter->next) {
//                if (iter->name == "property") {
//                    switch (iter->get_prop ("name")) {
//                         case "port":
//                             port = iter->get_content ();
//                             break;
//                         case
//                        default:
//                            break;
//                    }
//                }
//            }
//        }
//    }
//
    /**
     * Start the dry feeder.
     */

    public bool run () {
        message ("BrabenderModule.run");
        return true;
    }

    /**
     * Stop the dry feeder.
     */

    public bool stop () {
        message ("BrabenderModule.stop");
        return true;
    }

    /**
     * Callback event that handles new data seen on the modbus port.
     */
    private bool new_data_cb () {
        uint16 reg[59];

        (this.port as ModbusPort).read_registers (0x10, reg);
        var id = "br0";
        /** Assign the channel the value that was received
         *  XXX Actual values should be enumerated and parsed
         *  For now this is hard coded.
         **/
        var channel = channels.get (id);
        (channel as VChannel).raw_value = get_double (reg[0:2]);
        id = "br1";
        channel = channels.get (id);
        (channel as VChannel).raw_value = get_double (reg[2:4]);
        return false;
        }

    private double get_double (uint16[] reg) {
        uint16 reg1[2];
        double num = 0;
        /* Swap bytes. */
        reg1[0] = reg[1];
        reg1[1] = reg[0];
        num = (this.port as ModbusPort).get_float (reg1);
        return num;
    }

    /**
     * Set the operating mode.
     */
    public bool set_operating_mode (int mode) {
        return true;
     }

    /**
     * Set the set point
     */
    public bool set_set_point () {//ModbusPort port, double sp) {
        return true;
    }

    /**
     * Set the speed
     */
    public bool set_speed () {//ModbusPort port, double speed) {
        return true;
    }

    /**
     * {@inheritDoc}
     */
    public override bool load () {
        if (!port.open ()){
            message ("Couldn load id:%s", id);
            return false;
        }
        loaded = true;
        message ("BrabenderModule loaded");

        return true;
    }

    /**
     * {@inheritDoc}
     */
    public override void unload () {
        port.close ();

        loaded = false;
    }

    /**
     * {@inheritDoc}
     */
    public override string to_string () {
        string r;
        r  = "Brabender Module: [%s]\n".printf (id);
        return r;
    }
}
