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
 * Brabender ISC-CM Plus implementing TCP/IP Modbus
 */
using Modbus;
using Math;

public class Cld.BrabenderModule : AbstractModule {
    /**
     * Class constants.
     */
    double eps = 0.0001;
    int timeout_ms = 100;
    int time_us = 250000;
    uint source_id;

    const int MF_SP_WRITE_ADDR = 0x10;
    const int DI_SP_WRITE_ADDR = 0x14;
    const int MF_SP_READ_ADDR = 0x10;
    const int DI_SP_READ_ADDR = 0x1C;
    const int MF_AV_READ_ADDR = 0x12;
    const int DI_AV_READ_ADDR = 0x16;
    const int AUTO_TARE_READ_ADDR = 0x20;
    const int MODE_ADDR = 0x0A;
    const int FUNC_ADDR = 0x08;
    const int STATUS_ADDR = 0x08;
    const int ALARM_ADDR = 0x09;
    const int FREE_WRITE_VAL = 0x00;
    const int START_WRITE_VAL = 0x01;
    const int STOP_WRITE_VAL = 0x02;
    const int RESET_ALARM_WRITE_VAL = 0x03;
    const int ENABLE_OP1_WRITE_VAL = 0x10;
    const int STARTED_MASK = 0x1000;
    const int OP1_ENABLED_MASK = 0x0003;

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

    public bool running { get; set; default = false; }

    public weak Gee.Map<string, Object> channels { get; set; }

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
    public BrabenderModule.from_xml_node (Xml.Node *node) {
        debug ("Starting..");
        if (node->type == Xml.ElementType.ELEMENT_NODE &&
            node->type != Xml.ElementType.COMMENT_NODE) {
            id = node->get_prop ("id");
            /* iterate through node children */
            for (Xml.Node *iter = node->children;
                 iter != null;
                 iter = iter->next) {
                if (iter->name == "property") {
                    switch (iter->get_prop ("name")) {
                         case "portref":
                            portref = iter->get_content ();
                             break;
                         default:
                            break;
                    }
                }
            }
        }
    }

    /**
     * XXX This method does not work - Reset alarms.
     */
    public bool reset_alarm () {
        bool status = true;
        uint16[] data_in = new uint16[1];
        int write_val = RESET_ALARM_WRITE_VAL;

        write_val <<= 8;
        (this.port as ModbusPort).write_register (FUNC_ADDR, write_val);
        Posix.usleep(time_us);
        (this.port as ModbusPort).read_registers (STATUS_ADDR, data_in);
        debug ("status: data_in[0]: %.4x, write_val: %.4x", data_in[0], write_val);
        (this.port as ModbusPort).read_registers (ALARM_ADDR, data_in);
        debug ("alarm: data_in[0]: %.4x, write_val: %.4x", data_in[0], write_val);

        return status;
    }
    /**
     * XXX This method does not work - Enable the OP1 touch screen interface.
     */
    public bool enable_op1 () {
        bool status = true;
        uint16[] data_in = new uint16[1];
        int write_val = ENABLE_OP1_WRITE_VAL;

        write_val <<= 8;
        (this.port as ModbusPort).write_register (FUNC_ADDR, write_val);
        Posix.usleep (time_us);
        (this.port as ModbusPort).read_registers (STATUS_ADDR, data_in);
        //debug ("status: data_in[0]: %.4x, write_val: %.4x", data_in[0], write_val);
        if (!(((int) data_in[0] & OP1_ENABLED_MASK) == OP1_ENABLED_MASK)) {
            warning ("Brabender OP1 interface is not enabled");
            status = false;
        }

        return status;
    }

    /**
     * Start the dry feeder.
     */
    public bool run () {
        bool status = true;
        uint16[] data_in = new uint16[1];
        int write_val = START_WRITE_VAL;

        write_val <<= 8;
        (this.port as ModbusPort).write_register (FUNC_ADDR, write_val);
        Posix.usleep (time_us);
        (this.port as ModbusPort).read_registers (STATUS_ADDR, data_in);
        //debug ("data_in[0]: %.4x, write_val: %.4x",data_in[0] ,write_val);
        if (!((data_in[0] &  STARTED_MASK) == STARTED_MASK)) {
            warning ("Brabender Module start command not responding.");
            status = true;
            running = false;
        }
        else {
            running = true;
        }
        /* Enable starting if already stopped by OP1 */
        write_val = FREE_WRITE_VAL;
        write_val <<= 8;
        (this.port as ModbusPort).write_register (FUNC_ADDR, FREE_WRITE_VAL);

        return status;
    }

    /**
     * Stop the dry feeder.
     */

    public bool stop () {
        bool status = true;
        uint16[] data_in = new uint16[1];
        int write_val = STOP_WRITE_VAL;

        write_val <<= 8;
        (this.port as ModbusPort).write_register (FUNC_ADDR, write_val);
        Posix.usleep (time_us);
        (this.port as ModbusPort).read_registers (STATUS_ADDR, data_in);
        // debug ("status: data_in[0]: %.4x, write_val: %.4x", data_in[0], write_val);
        if (((data_in[0] & STARTED_MASK) == STARTED_MASK)) {
            warning ("Brabender Module stop command not responding.");
            status = false;
        }
        else {
            running = false;
        }
        /* Enable stoping if already started by OP1 */
        write_val = FREE_WRITE_VAL;
        write_val <<= 8;
        (this.port as ModbusPort).write_register (FUNC_ADDR, write_val);

        return status;
    }

    /**
     * Callback event that handles new data seen on the modbus port.
     */
    private bool new_data_cb () {
        uint16[] data = new uint16[2];

        if ((this.port as ModbusPort).connected == true) {
            var channel = channels.get ("br00");
            (this.port as ModbusPort).read_registers (MF_AV_READ_ADDR, data);
            (channel as VChannel).raw_value = get_double (data);
            channel = channels.get ("br01");
            (this.port as ModbusPort).read_registers (DI_AV_READ_ADDR, data);
            (channel as VChannel).raw_value = get_double (data);
//            (this.port as ModbusPort).read_registers (AUTO_TARE_READ_ADDR, data);
//            debug ("Auto-Tare value [kg]: %.3f", get_double (data));
        }

        return true;
    }

    private double get_double (uint16[] reg) {
        uint16[] reg1 = new uint16[2];
        double num = 0.0;

        /* Swap bytes. */
        reg1[0] = reg[1];
        reg1[1] = reg[0];
        num = Modbus.get_float (reg1);

        return num;
    }

    private void set_double (double val, uint16[] reg) {
        uint16[] reg1 = new uint16[2];

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
        int mode = 0;
        uint16[] data_in = new uint16[1];

        switch (mode_string) {
        case "GF":
            mode = GF;
            status = true;
            break;
        case "DI":
            mode = DI;
            status = true;
            break;
        default:
            warning ("Unknown Brabender operating mode: %s", mode_string);
            break;
        }
        if (status == true) {
            mode <<= 8;
            (this.port as ModbusPort).write_register (MODE_ADDR, mode);
            Posix.usleep (time_us);  // Need to wait beween read and write.
            (this.port as ModbusPort).read_registers (MODE_ADDR, data_in);
            debug ("data_in: (0x%X) mode: (0x%X)", data_in[0], mode);
            if (!((int) data_in[0] == mode)) {
                                warning ("Brabender Module: Unable to verify mode setting.");
                                status = false;
            }
        }

        return status;
     }

    /**
     * Set the mass flow rate setpoint [kg/min].
     */
    public bool set_mass_flow (double setpoint) {
        bool status = true;
        uint16[] data_out = new uint16[2];
        uint16[] data_in = new uint16[2];
        double setpoint_in;

        set_double (setpoint, data_out);
        /* Swap bytes. */
        (this.port as ModbusPort).write_registers (MF_SP_WRITE_ADDR, data_out);
        Posix.usleep (200000);
        (this.port as ModbusPort).read_registers (MF_SP_READ_ADDR, data_in);
        setpoint_in = get_double (data_in);
        debug ("setpoint: %.6f setpoint_in: %.6f", setpoint, setpoint_in);
        if (fabs (setpoint - setpoint_in) > eps) {
            warning("Brabender Module: Unable to verify mass flow rate setpoint.");
            status = false;
        }

        return status;
    }

    /**
     * Set the discharge speed [%].
     */
    public bool set_discharge (double setpoint) {
        bool status = true;
        uint16[] data_out = new uint16[2];
        uint16[] data_in = new uint16[2];
        double setpoint_in;

        set_double (setpoint, data_out);
        /* Swap bytes. */
        (this.port as ModbusPort).write_registers (DI_SP_WRITE_ADDR, data_out);
        Posix.usleep (200000);
        (this.port as ModbusPort).read_registers (DI_SP_READ_ADDR, data_in);
        setpoint_in = get_double (data_in);
        debug ("setpoint: %.6f setpoint_in: %.6f", setpoint, setpoint_in);
        if (fabs (setpoint - setpoint_in) > eps) {
            warning("Brabender Module: Unable to verify discharge rate setpoint.");
            status = false;
        }

        return status;
    }

    /**
     * {@inheritDoc}
     */
    public override bool load () {
        loaded = true;
        if (!port.open ()) {
            warning ("Could not open port, id:%s", id);
            loaded = false;
        }
        else {
            stop ();
            //enable_op1 ();
            reset_alarm ();
            source_id = Timeout.add (timeout_ms, new_data_cb);
            debug ("BrabenderModule loaded");
        }
        return loaded;
    }

    /**
     * {@inheritDoc}
     */
    public override void unload () {
        if (running)
            stop ();
        if (loaded) {
            port.close ();
        loaded = false;
        }
        debug ("BrabenderModule unloaded");
    }
}
