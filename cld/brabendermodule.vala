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
using Modbus;

public class Cld.BrabenderModule : AbstractModule {
    int timeout_ms = 100;
    const int MF_SP_WRITE_ADDR = 0x10;
    const int DF_SP_WRITE_ADDR = 0x14;
    const int MF_SP_READ_ADDR = 0x10;
    const int DI_SP_READ_ADDR = 0x1C;
    const int MF_VAL_ADDR = 0x12;
    const int SPEED_READ_ADDR = 0x16;
    const int AUTO_TARE_READ_ADDR = 0x20;
    const int MODE_ADDR = 0x0A;
    const int FUNC_ADDR = 0x08;
    const int STATUS_ADDR = 0x08;
    const int FREE_WRITE_VAL = 0x00;
    const int START_WRITE_VAL = 0x01;
    const int STOP_WRITE_VAL = 0x02;
    const int STARTED_MASK = 0x0100;
    /**
     * Operating Modes
     */
    const int FREE0 = 0;
    const int GF = 1;
    const int VR = 2;
    const int VS = 3;
    const int DI = 4;
    const int CM = 5;
    const int GD = 6;
    const int VF = 7;
    const int FREE1 = 8;
    const int AT = 9;
    const int FREE2 = 10;
    const int GM = 11;
    const int BF = 12;
    const int BM = 13;
    const int FREE3 = 14;
    const int FREE4 = 15;

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
     * Default construction.
     */
    public BrabenderModule () {
        }

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
        bool status = true;
        uint16[1] data;
        int x;

        (this.port as ModbusPort).write_register (FUNC_ADDR, START_WRITE_VAL);
        (this.port as ModbusPort).read_registers (STATUS_ADDR, data);
        x = data[0];
        if (!((x &  STARTED_MASK) == STARTED_MASK)) {
            critical ("Brabender Module start command not responding.");
            status = false;
        }
        /* Enable starting if already stopped by OP1 */
        (this.port as ModbusPort).write_register (FUNC_ADDR, FREE_WRITE_VAL);

        return status;
    }

    /**
     * Stop the dry feeder.
     */

    public bool stop () {
        bool status = true;
        uint16[1] data;
        int x;

        (this.port as ModbusPort).write_register (FUNC_ADDR, STOP_WRITE_VAL);
        (this.port as ModbusPort).read_registers (STATUS_ADDR, data);
        x = data[0];
        if (((x & STARTED_MASK) == STARTED_MASK)) {
            critical ("Brabender Module stop command not responding.");
            status = false;
        }
        /* Enable stoping if already started by OP1 */
        (this.port as ModbusPort).write_register (FUNC_ADDR, FREE_WRITE_VAL);

        return status;
    }

    /**
     * Callback event that handles new data seen on the modbus port.
     */
    private bool new_data_cb () {
        uint16[2] data;

        if ((this.port as ModbusPort).connected == true) {
            var channel = channels.get ("br0");
            (this.port as ModbusPort).read_registers (MF_SP_READ_ADDR, data);
            (channel as VChannel).raw_value = get_double (data);
            channel = channels.get ("br1");
            (this.port as ModbusPort).read_registers (DI_SP_READ_ADDR, data);
            (channel as VChannel).raw_value = get_double (data);
            (this.port as ModbusPort).read_registers (AUTO_TARE_READ_ADDR, data);
            message ("Auto-Tare value [kg]: %.3f", get_double (data));
        }

        return true;
    }

    private double get_double (uint16[] reg) {
        uint16 reg1[2];
        double num = 0;

        /* Swap bytes. */
        reg1[0] = reg[1];
        reg1[1] = reg[0];
        num = Modbus.get_float (reg1);

        return num;
    }

    private void set_double (double val, uint16[] reg) {
        uint16[2] reg1;

        Modbus.set_float ((float) val, reg1);
        /* Swap bytes. */
        reg[0] = reg1[1];
        reg[1] = reg1[0];

        }


    /**
     * Set the operating mode.
     */
    public bool set_mode (string mode_string) {
        bool status = false;
        int mode;
        uint16 data[1];

        switch (mode_string) {
        case "GF":
            mode = GF;
            status = true;
        case "DI":
            mode = DI;
            status = true;
        }
        if (status == true) {
            (this.port as ModbusPort).write_register (MODE_ADDR, mode);
            (this.port as ModbusPort).read_registers (MODE_ADDR, data);
            if (!(data[0] == mode)) {
                critical ("Brabender Module: Unable to verify mode setting.");
                status = false;
            }
        }
        /* Arm device to receive a new command */
        (this.port as ModbusPort).write_register (MODE_ADDR, FREE0);

        return status;
     }

    /**
     * Set the mass flow rate setpoint [kg/min].
     */
    public bool set_mass_flow (double setpoint) {
        bool status = true;
        uint16[2] data_out;
        uint16[2] data_in;
        double setpoint_in;

        set_double (setpoint, data);
        (this.port as ModbusPort).write_register (MF_SP_WRITE_ADDR, data_out);
        (this.port as ModbusPort).read_register (MF_SP_WRITE_ADDR, setpoint_in);
        if (!(setpoint == setpoint_in)) {
            critical("Brabender Module:Unable to verify mass flow rate setpoint.");
            status = false;
        }

        return status;
    }

    /**
     * Set the discharge speed [%].
     */
    public bool set_discharge (double setpoint) {
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
        uint source_id = Timeout.add (timeout_ms, new_data_cb);

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
