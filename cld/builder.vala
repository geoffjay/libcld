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
 * Author:
 *  Geoff Johnson <geoff.jay@gmail.com>
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

    public Gee.Map<string, Cld.Object> objects {
        get { return container.objects; }
    }

    construct {
        container = new Cld.SimpleContainer ();
        container.id = "ctr0";
        container.parent = null;
    }

    public Builder.from_file (string filename) {
        xml = new Cld.XmlConfig.with_file_name (filename);
        build_object_map (container, 0);
    }

    public Builder.from_xml_config (Cld.XmlConfig xml) {
        this.xml = xml;
        build_object_map (container, 0);
    }

    /**
     * Constructs the object tree using the top level object types.
     */
    private void build_object_map (Cld.Container ctr, int level) {
        Cld.Object object = null;
        string xpath = "/cld/cld:objects";

        for (int i = 0; i < level + 1; i++) {
            if (level > 0 && i == level - 1) {
                xpath += "/cld:object[@id = %s]".printf (ctr.id);
            } else {
                xpath += "/cld:object";
            }
        }

        Cld.debug ("Adding nodeset to %s for: %s", ctr.id, xpath);

        /* request the nodeset from the configuration */
        try {
            Xml.XPath.NodeSet *nodes = xml.nodes_from_xpath (xpath);

            for (int i = 0; i < nodes->length (); i++) {
                Xml.Node *node = nodes->item (i);
                if (node->type == Xml.ElementType.ELEMENT_NODE &&
                    node->type != Xml.ElementType.COMMENT_NODE) {

                    /* Load all available objects */
                    if (node->name == "object") {
                        Cld.debug ("Level: %d", level);
                        object = node_to_object (node);

                        /* Recursively add objects */
                        if (object is Cld.Container) {
                            build_object_map (object as Cld.Container, level + 1);
                        }

                        /* assign container as parent */
                        object.parent = ctr;

                        /* No point adding an object type that isn't recognized */
                        if (object != null) {
                            try {
                                Cld.debug ("Adding object of type %s with id %s to %s",
                                           ((object as GLib.Object).get_type ()).name (),
                                           object.id, ctr.id);
                                ctr.add (object);
                            } catch (Cld.Error.KEY_EXISTS e) {
                                Cld.error (e.message);
                            }
                        }
                    }
                }
            }
        } catch (Cld.XmlError e) {
            Cld.error (e.message);
        }
    }

    private Cld.Object? node_to_object (Xml.Node *node) {
        Cld.Object object = null;
        string type = node->get_prop ("type");

        switch (type) {
            case "control":
                object = new Control.from_xml_node (node);
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
            default:
                break;
        }

        Cld.debug ("Loading object of type %s with id %s", type, object.id);

        return object;
    }

    private Cld.Object? node_to_controller (Xml.Node *node) {
        Cld.Object object = null;

        var ctype = node->get_prop ("ctype");
        if (ctype == "acquisition") {
            object = new AcquisitionController.from_xml_node (node);
        } else if (ctype == "log") {
            object = new LogController.from_xml_node (node);
        } else if (ctype == "automation") {
            object = new AutomationController.from_xml_node (node);
        }

        return object;
    }

    private Cld.Object? node_to_log (Xml.Node *node) {
        Cld.Object object = null;

        var ltype = node->get_prop ("ltype");
        if (ltype == "csv") {
            object = new CsvLog.from_xml_node (node);
        } else if (ltype == "sqlite") {
            object = new SqliteLog.from_xml_node (node);
        }

        return object;
    }

    private Cld.Object? node_to_channel (Xml.Node *node) {
        Cld.Object object = null;

        var ctype = node->get_prop ("ctype");
        var direction = node->get_prop ("direction");

        if (ctype == "analog" && direction == "input") {
            object = new Cld.AIChannel.from_xml_node (node);
        } else if (ctype == "analog" && direction == "output") {
            object = new Cld.AOChannel.from_xml_node (node);
        } else if (ctype == "digital" && direction == "input") {
            object = new Cld.DIChannel.from_xml_node (node);
        } else if (ctype == "digital" && direction == "output") {
            object = new Cld.DOChannel.from_xml_node (node);
        } else if (ctype == "virtual") {
            object = new Cld.VChannel.from_xml_node (node);
        } else if (ctype == "calculation") {
            object = new Cld.MathChannel.from_xml_node (node);
        }

        return object;
    }

    private Cld.Object? node_to_module (Xml.Node *node) {
        Cld.Object object = null;

        var mtype = node->get_prop ("mtype");
        if (mtype == "velmex") {
            object = new VelmexModule.from_xml_node (node);
        } else if (mtype == "licor") {
            object = new LicorModule.from_xml_node (node);
        } else if  (mtype == "brabender") {
            object = new BrabenderModule.from_xml_node (node);
        } else if (mtype == "parker") {
            object = new ParkerModule.from_xml_node (node);
        } else if  (mtype == "heidolph") {
            object = new HeidolphModule.from_xml_node (node);
        }

        return object;
    }

    private Cld.Object? node_to_port (Xml.Node *node) {
        Cld.Object object = null;

        var ptype = node->get_prop ("ptype");
        if (ptype == "serial") {
            object = new SerialPort.from_xml_node (node);
        } else if (ptype == "modbus") {
            object = new ModbusPort.from_xml_node (node);
        }

        return object;
    }

    /**
     * Sets up all of the weak references between the objects in the tree that
     * require it.
     */
    private void setup_references () {
        string ref_id;

        var channel_map = container.get_object_map (typeof (Cld.Channel));

        foreach (var object in container.objects.values) {
            /* Setup the device references for all of the channel types */
            if (object is Channel) {
                ref_id = (object as Channel).devref;
                Cld.debug ("Assigning Device %s to Channel %s", ref_id, object.id);
                var device = container.get_object (ref_id);
                if (device != null && device is Device) {
                    (object as Channel).device = (device as Device);
                    ref_id = (object as Channel).taskref;
                    Cld.debug ("Assigning Task %s to Channel %s", ref_id, object.id);
                    var task = (device as Cld.Container).get_object (ref_id);
                    if (task != null && task is Task)
                        (object as Channel).task = (task as Task);
                }
            }

            /* Channels with a calibration reference */
            if (object is Cld.ScalableChannel) {
                ref_id = (object as Cld.ScalableChannel).calref;
                Cld.debug ("Assigning Calibration %s to ScalableChannel %s", ref_id, object.id);
                if (ref_id != null) {
                    var calibration = container.get_object (ref_id);
                    if (calibration != null && calibration is Calibration)
                        (object as Cld.ScalableChannel).calibration =
                                                (calibration as Calibration);
                }
            }

            if (object is Cld.MathChannel) {
                if ((object as Cld.MathChannel).expression != null) {
                    int len = (object as Cld.MathChannel).variable_names.length;
                    for (int i = 0; i < len; i++) {
                        Cld.Object obj;
                        string name  = (object as Cld.MathChannel).variable_names [i];
                        foreach (string id in container.objects.keys) {
                            obj = container.get_object (id);
                            if (name.contains (id) && (container.objects.get (id) is DataSeries)) {
                                (((obj as DataSeries).channel) as Cld.ScalableChannel).new_value.connect ((id, val) => {
                                double num = (object as Cld.MathChannel).calculated_value;
                            });

                            } else if (name == id && (container.objects.get (id) is Cld.ScalableChannel)) {
                                obj = container.get_object (id);
                                (obj as Cld.ScalableChannel).new_value.connect ((id, val) => {
                                    double num = (object as Cld.MathChannel).calculated_value;
                                });
                            } else {
                                obj = null;
                            }
                            if (obj != null) {
                                (object as Cld.MathChannel).add_object (id, obj);
                                Cld.debug ("Assigning Cld.Object %s to MathChannel %s", name, object.id);
                            }
                        }
                    }
                }
            }

            if (object is VChannel) {
                /* For now virtual channels do too */
                ref_id = (object as VChannel).calref;
                if ((object as VChannel).expression != null) {
                    foreach( var name in (object as VChannel).channel_names ) {
                        (object as VChannel).add_channel (name, (container.get_object (name) as AIChannel));
                    }
                }
            }

            /* Setup the channel references for all of the log columns. */
            if (object is Cld.Log) {
                foreach (var column in (object as Container).objects.values) {
                    if (column is Column) {
                        ref_id = (column as Column).chref;
                        if (ref_id != null) {
                            var channel = container.get_object (ref_id);
                            if (channel != null && channel is Channel) {
                                Cld.debug ("Assigning channel %s to column %s", channel.id, column.id);
                                (column as Column).channel = (channel as Channel);
                            }
                        }
                    }
                }

                /* Following the setup of the log columns, the log needs to attach the signals. */
                (object as Cld.Log).connect_signals ();

                /* Add a FIFO buffer to the Log for data from each ComediTask. */
                add_fifos (object as Cld.Log);
            }

            /* Setup port references for all of the modules */
            if (object is Module) {

                ref_id = (object as Module).portref;
                Cld.debug ("Assigning Port %s to Module %s", ref_id, object.id);
                if (ref_id != null) {
                    var port = container.get_object (ref_id);
                    if (port != null && port is Port)
                        (object as Module).port = (port as Port);
                }

                ref_id = (object as Module).devref;

                if (ref_id != null && object is LicorModule) {
                    /* set the virtual channel that are to be referenced by this module */
                    foreach (var licor_channel in channel_map.values) {
                        if ((licor_channel as Channel).devref == ref_id) {
                            Cld.debug ("Assigning Channel %s to Device %s", licor_channel.id,
                                        (object as LicorModule).devref);
                            (object as LicorModule).add_channel (licor_channel);
                        }
                    }
                }

                if (ref_id != null && object is ParkerModule) {
                    /* set the virtual channels that are to be referenced by this module */
                    foreach (var parker_channel in channel_map.values) {
                        if ((parker_channel as Channel).devref == ref_id) {
                            Cld.debug ("Assigning Channel %s to Device %s", parker_channel.id,
                                        (object as ParkerModule).devref);
                            (object as ParkerModule).add_channel (parker_channel);
                        }
                    }
                }
                if (object is HeidolphModule) {
                    var chan0 = container.get_object ("heidolph00");
                    var chan1 = container.get_object ("heidolph01");
                    (object as HeidolphModule).add_channel (chan0 as Channel);
                    (object as HeidolphModule).add_channel (chan1 as Channel);

                    /* set the virtual channel that are to be referenced by this module */
//                    foreach (var heidolph_channel in channels.values) {
//                        Cld.debug ("ref_id: %s heidolph_channel.id: %s", ref_id, heidolph_channel.id);
//                        if ((heidolph_channel as Channel).devref == ref_id) {
//                            Cld.debug ("Assigning Channel %s to Module %s", heidolph_channel.id,
//                                        (object as HeidolphModule).id);
//                            (object as HeidolphModule).add_channel (heidolph_channel);
//                        }
//                    }
                }
            }

            /* A  data series references a scalable channel. */
            if (object is DataSeries) {
                ref_id = (object as DataSeries).chref;
                Cld.debug ("Assigning Channel %s to DataSeries %s", ref_id, object.id);
                (object as DataSeries).channel = container.get_object (ref_id) as Cld.ScalableChannel;
                Cld.debug ("Connecting ScalableChannel as input to DataSeries %s", object.id);
                (object as DataSeries).connect_input ();
                Cld.debug ("Activating VChannels in DataSeries %s", object.id);
                (object as DataSeries).activate_vchannels ();
            }

            /* XXX Too much nesting, should break into individual methods. */
            if (object is Control) {
                foreach (var control_object in
                            (object as Container).objects.values) {
                    if (control_object is Pid) {
                        foreach (var process_value in
                                    (control_object as Pid).process_values.values) {
                            /* Process values reference a channel */
                            if (process_value is ProcessValue) {
                                ref_id = (process_value as ProcessValue).chref;
                                Cld.debug ("Assigning ProcessValue %s to Control %s", ref_id, object.id);
                                if (ref_id != null) {
                                    var channel = container.get_object (ref_id);
                                    if (channel != null && channel is Channel) {
                                        (process_value as ProcessValue).channel
                                            = (channel as Channel);
                                    }
                                }
                            }
                        }
                    }
                    if (control_object is Pid2) {
                        foreach (var process_value in
                                    (control_object as Pid2).process_values.values) {
                            /* Process values reference a channel */
                            if (process_value is ProcessValue2) {
                                ref_id = (process_value as ProcessValue2).dsref;
                                Cld.debug ("Assigning ProcessValue2 %s to Control %s", ref_id, object.id);
                                if (ref_id != null) {
                                    var dataseries = container.get_object (ref_id);
                                    if (dataseries != null && dataseries is DataSeries) {
                                        (process_value as ProcessValue2).dataseries
                                            = (dataseries as DataSeries);
                                        var chref = (dataseries as DataSeries).chref;
                                        (process_value as ProcessValue2).dataseries.channel = container.get_object (chref)
                                                                                    as Cld.ScalableChannel;
                                    }
                                }
                            }
                        }
                        ref_id = (control_object as Pid2).sp_chref;
                        if (ref_id != null) {
                            var channel = container.get_object (ref_id);
                            if (channel != null && channel is Cld.ScalableChannel) {
                                Cld.debug ("Assigning ScalableChannel %s to Pid2 %s", ref_id, control_object.id);
                                (control_object as Pid2).sp_channel = channel as Cld.ScalableChannel;
                                (control_object as Pid2).connect_sp ();
                            }
                        }
                    }
                }
            }

            /* Each device in daq references tasks.  */
            if (object is Daq) {
                foreach (var device in (object as Container).objects.values) {
                    foreach (var devobject in (device as Container).objects.values) {
                        if ((devobject is ComediTask) && (device is ComediDevice)) {
                            (devobject as ComediTask).device = (device as ComediDevice);
                            set_channels (devobject as ComediTask);
                        }
                    }
                }
            }
        }
    }

    /**
     * Set a channel list for a Comedi task.
     */
     public void set_channels (Cld.ComediTask task) {
        var channel_map = container.get_object_map (typeof (Cld.Channel));

        /* Build a channel list for this task. */
        foreach (var channel in channel_map.values) {
            if (((channel as Cld.Channel).taskref == (task as Cld.ComediTask).id) &&
                ((channel as Cld.Channel).devref == (task as Cld.ComediTask).devref)) {
                (task as Cld.ComediTask).add_channel (channel);
            }
        }
     }

    /**
     * Add FIFOS to a Cld.Log.
     * XXX This method is quite cumbersome and should be simplified.
     */
    public void add_fifos (Cld.Log log) {
        var daq_map = container.get_object_map (typeof (Cld.Daq));

        foreach (var daq in daq_map.values) {
            var device_map = (daq as Cld.Container).get_object_map (typeof (Cld.Device));
            foreach (var device in device_map.values) {
                var task_map = (device as Cld.Container).get_object_map (typeof (Cld.Task));
                foreach (var task in task_map.values) {
                    if (task is Cld.ComediTask) {
                        /* Request a FIFO and add it to fifos */
                        int fd;
                        string fname = (task as Cld.ComediTask).connect_fifo (log.id, out fd);
                        log.fifos.set (fname, fd);
                    }
                }
            }
        }
    }
}
