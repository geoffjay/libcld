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
 * Class use to build objects from configuration data.
 */
internal class Cld.Builder : GLib.Object {

    /**
     * The XML configuration to use for building
     */
    private Cld.XmlConfig xml;

    private Cld.Container container;

/*
 *    public Gee.Map<string, Cld.Object> objects {
 *        get {
 *            unowned Gee.Map<string, Cld.Object> objs = container.get_objects ();
 *
 *            return objs;
 *            }
 *    }
 */
    public Gee.Map<string, Cld.Object> objects;

    construct {
        container = new Cld.RootContainer ();
        container.id = "root";
    }

    public Builder.from_file (string filename) {
        xml = new Cld.XmlConfig.with_file_name (filename);
        build_object_map (container, 0);
    }

    public Builder.from_xml_config (Cld.XmlConfig xml) {
        this.xml = xml;
        build_object_map (container, 0);
    }

    public Gee.Map<string, Cld.Object> get_objects () {
        objects = container.get_objects ();

        return objects;
    }

    /**
     * Constructs the object tree using the top level object types.
     */
    private void build_object_map (Cld.Container ctr, int level) {
        Cld.Object object = null;
        string xpath = "/cld/cld:objects";

        for (int i = 0; i < level + 1; i++) {
            if (level > 0 && i == level - 1)
                xpath += "/cld:object[@id = %s]".printf (ctr.id);
            else
                xpath += "/cld:object";
        }

        debug ("Adding nodeset to %s for: %s", ctr.id, xpath);

        /* request the nodeset from the configuration */
        try {
            Xml.XPath.NodeSet *nodes = xml.nodes_from_xpath (xpath);

            for (int i = 0; i < nodes->length (); i++) {
                Xml.Node *node = nodes->item (i);
                if (node->type == Xml.ElementType.ELEMENT_NODE &&
                    node->type != Xml.ElementType.COMMENT_NODE) {

                    /* Load all available objects */
                    if (node->name == "object") {
                        debug (" > Level: %d", level);
                        object = node_to_object (node);

                        /* Recursively add objects */
                        if (object is Cld.Container)
                            build_object_map (object as Cld.Container, level + 1);

                        /* No point adding an object type that isn't recognized */
                        if (object != null) {
                            try {
                                debug ("   > Adding object of type %s with id %s to %s",
                                         ((object as GLib.Object).get_type ()).name (),
                                         object.id, ctr.id);
                                ctr.add (object);
                            } catch (Cld.Error.KEY_EXISTS e) {
                                error (e.message);
                            }
                        }
                    }
                }
            }
        } catch (Cld.XmlError e) {
            error (e.message);
        }
    }

    private Cld.Object? node_to_object (Xml.Node *node) {
        Cld.Object object = null;

        var type = node->get_prop ("type");

        switch (type) {
            case "pid":
                object = new Cld.Pid.from_xml_node (node);
                break;
            case "pid-2":
                object = new Cld.Pid2.from_xml_node (node);
                break;
            case "controller":
                object = node_to_controller (node);
                break;
            case "calibration":
                object = new Calibration.from_xml_node (node);
                break;
            case "channel":
                object = node_to_channel (node);
                break;
            case "dataseries":
                object = new DataSeries.from_xml_node (node);
                break;
            case "daq":
                object = new Daq.from_xml_node (node);
                break;
            case "log":
                object = node_to_log (node);
                break;
            case "module":
                object = node_to_module (node);
                break;
            case "port":
                object = node_to_port (node);
                break;
            case "sensor":
                object = node_to_sensor (node);
                break;
            default:
                break;
        }

        debug ("Loading object of type %s with id %s", type, object.id);

        return object;
    }

    private Cld.Object? node_to_controller (Xml.Node *node) {
        Cld.Object object = null;

        var ctype = node->get_prop ("ctype");

        if (ctype == "acquisition")
            object = new AcquisitionController.from_xml_node (node);
        else if (ctype == "log")
            object = new LogController.from_xml_node (node);
        else if (ctype == "automation")
            object = new AutomationController.from_xml_node (node);

        return object;
    }

    private Cld.Object? node_to_log (Xml.Node *node) {
        Cld.Object object = null;

        var ltype = node->get_prop ("ltype");

        if (ltype == "csv")
            object = new CsvLog.from_xml_node (node);
        else if (ltype == "sqlite")
            object = new SqliteLog.from_xml_node (node);

        return object;
    }

    private Cld.Object? node_to_channel (Xml.Node *node) {
        Cld.Object object = null;

        var ctype = node->get_prop ("ctype");
        var direction = node->get_prop ("direction");

        if (ctype == "analog" && direction == "input")
            object = new Cld.AIChannel.from_xml_node (node);
        else if (ctype == "analog" && direction == "output")
            object = new Cld.AOChannel.from_xml_node (node);
        else if (ctype == "digital" && direction == "input")
            object = new Cld.DIChannel.from_xml_node (node);
        else if (ctype == "digital" && direction == "output")
            object = new Cld.DOChannel.from_xml_node (node);
        else if (ctype == "virtual")
            object = new Cld.VChannel.from_xml_node (node);
        else if (ctype == "calculation")
            object = new Cld.MathChannel.from_xml_node (node);
        else if (ctype == "raw")
            object = new Cld.RawChannel.from_xml_node (node);
        return object;
    }

    private Cld.Object? node_to_module (Xml.Node *node) {
        Cld.Object object = null;

        var mtype = node->get_prop ("mtype");

        if (mtype == "velmex")
            object = new VelmexModule.from_xml_node (node);
        else if (mtype == "licor")
            object = new LicorModule.from_xml_node (node);
        else if  (mtype == "brabender")
            object = new BrabenderModule.from_xml_node (node);
        else if (mtype == "parker")
            object = new ParkerModule.from_xml_node (node);
        else if  (mtype == "heidolph")
            object = new HeidolphModule.from_xml_node (node);

        return object;
    }

    private Cld.Object? node_to_port (Xml.Node *node) {
        Cld.Object object = null;

        var ptype = node->get_prop ("ptype");

        if (ptype == "serial")
            object = new SerialPort.from_xml_node (node);
        else if (ptype == "modbus")
            object = new ModbusPort.from_xml_node (node);

        return object;
    }

    private Cld.Object? node_to_sensor (Xml.Node *node) {
        Cld.Object object = null;

        var type = node->get_prop ("sensor-type");

        if (type == "flow")
            object = new FlowSensor.from_xml_node (node);

        return object;
    }
}
