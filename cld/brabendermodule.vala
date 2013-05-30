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
    public BrabenderModule () { }

    /**
     * Full construction using available settings.
     */
    public BrabenderModule.full (string id, Port port) {
        this.id = id;
        this.port = port;
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
    private void new_data_cb () {//ModbusPort port /* some data */) {

    /* XXX Hard code this for now to get speed or mass flow rate depending on mode setting. */
    }

    /**
     * Set the operating mode.
     */
    public bool set_operating_mode () {//ModbusPort port, Mode mode) {
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
//        if (!port.open ())
//            return false;

        loaded = true;

        return true;
    }

    /**
     * {@inheritDoc}
     */
    public override void unload () {
//        port.close ();

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
