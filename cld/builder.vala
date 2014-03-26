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
public class Cld.Builder : Cld.AbstractContainer {

    /**
     * {@inheritDoc}
     */
    public override string id { get; set; }

    /**
     * The XML configuration to use for building
     */
    private XmlConfig xml { get; set; }

    /**
     * {@inheritDoc}
     */
    private Gee.Map<string, Cld.Object> _objects;
    public override Gee.Map<string, Cld.Object> objects {
        get { return (_objects); }
        set { update_objects (value); }
    }

    private Daq _default_daq;
    public Daq default_daq {
        /* return the first available daq object */
        get {
            foreach (var object in objects.values) {
                if (object is Daq) {
                    _default_daq = (object as Daq);
                    break;
                }
            }
            return _default_daq;
        }
    }

    private Control _default_control;
    public Control default_control {
        /* return the first available control object */
        get {
            foreach (var object in objects.values) {
                if (object is Control) {
                    _default_control = (object as Control);
                    break;
                }
            }
            return _default_control;
        }
    }

    /* it might be wrong here to use null here because it might prevent
     * the user from adding objects manually after the first get and having
     * their changes be reflected in the list they hold - test and change
     * if that's the case */

    private Gee.Map<string, Cld.Object>? _calibrations = null;
    public Gee.Map<string, Cld.Object>? calibrations {
        get {
            if (_calibrations == null) {
                _calibrations = new Gee.TreeMap<string, Cld.Object> ();
                foreach (var object in objects.values) {
                    if (object is Calibration)
                        _calibrations.set (object.id, object);
                }
            }
            return _calibrations;
        }
    }

    private Gee.Map<string, Cld.Object>? _channels = null;
    public Gee.Map<string, Cld.Object>? channels {
        get {
            if (_channels == null) {
                _channels = new Gee.TreeMap<string, Cld.Object> ();
                foreach (var object in objects.values) {
                    if (object is Channel)
                        _channels.set (object.id, object);
                }
            }
            return _channels;
        }
    }

    private Gee.Map<string, Cld.Object>? _logs = null;
    public Gee.Map<string, Cld.Object>? logs {
        get {
            if (_logs == null) {
                _logs = new Gee.TreeMap<string, Cld.Object> ();
                foreach (var object in objects.values) {
                    if (object is Log)
                        _logs.set (object.id, object);
                }
            }
            return _logs;
        }
    }

    private Gee.Map<string, Cld.Object>? _modules = null;
    public Gee.Map<string, Cld.Object>? modules {
        get {
            if (_modules == null) {
                _modules = new Gee.TreeMap<string, Cld.Object> ();
                foreach (var object in objects.values) {
                    if (object is Module)
                        _modules.set (object.id, object);
                }
            }
            return _modules;
        }
    }

    private Gee.Map<string, Cld.Object>? _dataseries = null;
    public Gee.Map<string, Cld.Object>? dataseries {
        get {
            if (_dataseries == null) {
                _dataseries = new Gee.TreeMap<string, Cld.Object> ();
                foreach (var object in objects.values) {
                    if (object is DataSeries)
                        _dataseries.set (object.id, object);
                }
            }
            return _dataseries;
        }
        set { _dataseries = value; }
    }

    public Builder.from_file (string filename) {
        xml = new XmlConfig.with_file_name (filename);
        _objects = new Gee.TreeMap<string, Cld.Object> ();
        build_object_map ();
        setup_references ();
    }

    public Builder.from_xml_config (XmlConfig xml) {
        this.xml = xml;
        _objects = new Gee.TreeMap<string, Cld.Object> ();
        build_object_map ();
        setup_references ();
    }

    ~Builder () {
        if (objects != null)
            objects.clear ();
    }

    /**
     * {@inheritDoc}
     */
    public Cld.Object? get_object (string id) {
        Cld.Object? result = null;

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

    /**
     * Constructs the object tree using the top level object types.
     */
    private void build_object_map () {
        string type;
        string direction;
        string xpath = "/cld/cld:objects/cld:object";

        /* request the nodeset from the configuration */
        Xml.XPath.NodeSet *nodes = xml.nodes_from_xpath (xpath);
        Xml.Node *node = nodes->item (0);

        for (Xml.Node *iter = node; iter != null; iter = iter->next) {
            if (iter->type == Xml.ElementType.ELEMENT_NODE &&
                iter->type != Xml.ElementType.COMMENT_NODE) {
                /* load all available objects */
                if (iter->name == "object") {
                    Cld.Object object = null;
                    type = iter->get_prop ("type");
                    switch (type) {
                        case "daq":
                            object = new Daq.from_xml_node (iter);
                            break;
                        case "log":
                            var ltype = iter->get_prop ("ltype");
                            if (ltype == "csv") {
                                object = new CsvLog.from_xml_node (iter);
                            } else if (ltype == "sqlite") {
                                object = new SqliteLog.from_xml_node (iter);
                            }
                            break;
                        case "control":
                            object = new Control.from_xml_node (iter);
                            break;
                        case "calibration":
                            object = new Calibration.from_xml_node (iter);
                            break;
                        case "channel":
                            var ctype = iter->get_prop ("ctype");
                            direction = iter->get_prop ("direction");
                            if (ctype == "analog" && direction == "input") {
                                object = new AIChannel.from_xml_node (iter);
                            } else if (ctype == "analog" && direction == "output") {
                                object = new AOChannel.from_xml_node (iter);
                            } else if (ctype == "digital" && direction == "input") {
                                object = new DIChannel.from_xml_node (iter);
                            } else if (ctype == "digital" && direction == "output") {
                                object = new DOChannel.from_xml_node (iter);
                            } else if (ctype == "virtual") {
                                object = new VChannel.from_xml_node (iter);
                            } else if (ctype == "calculation") {
                                object = new MathChannel.from_xml_node (iter);
                            } else {
                                object = null;
                            }
                            break;
                        case "module":
                            var mtype = iter->get_prop ("mtype");
                            if (mtype == "velmex") {
                                object = new VelmexModule.from_xml_node (iter);
                            } else if (mtype == "licor") {
                                object = new LicorModule.from_xml_node (iter);
                            } else if  (mtype == "brabender") {
                                object = new BrabenderModule.from_xml_node (iter);
                            } else if (mtype == "parker") {
                                object = new ParkerModule.from_xml_node (iter);
                            } else if  (mtype == "heidolph") {
                                object = new HeidolphModule.from_xml_node (iter);
                            } else {
                                object = null;
                            } break;
                        case "port":
                            var ptype = iter->get_prop ("ptype");
                            if (ptype == "serial") {
                                object = new SerialPort.from_xml_node (iter);
                            } else if (ptype == "modbus") {
                                object = new ModbusPort.from_xml_node (iter);
                            } else {
                                object = null;
                            }
                            break;
                        case "dataseries":
                            object = new DataSeries.from_xml_node (iter);
                            break;
                        default:
                            object = null;
                            break;
                    }

                    Cld.debug ("Loading object of type %s with id %s", type, object.id);
                    if (object is Cld.Container) {
                        foreach (Cld.Object obj in (object as Cld.Container).objects.values) {
                            Cld.debug ("Loading object of type %s with id %s",
                                ((obj as GLib.Object).get_type ()).name, object.id);
                            add (obj);
                        }
                    }
                    /* no point adding an object type that isn't recognized */
                    if (object != null)
                        add (object);
                }
            }
        }
    }

    /**
     * Sets up all of the weak references between the objects in the tree that
     * require it.
     */
    private void setup_references () {
        string ref_id;

        foreach (var object in objects.values) {
            /* Setup the device references for all of the channel types */
            if (object is Channel) {
                ref_id = (object as Channel).devref;
                Cld.debug ("Assigning Device %s to Channel %s", ref_id, object.id);
                var device = get_object (ref_id);
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
            if (object is ScalableChannel) {
                ref_id = (object as ScalableChannel).calref;
                Cld.debug ("Assigning Calibration %s to ScalableChannel %s", ref_id, object.id);
                if (ref_id != null) {
                    var calibration = get_object (ref_id);
                    if (calibration != null && calibration is Calibration)
                        (object as ScalableChannel).calibration =
                                                (calibration as Calibration);
                }
            }

            if (object is MathChannel) {
                if ((object as MathChannel).expression != null) {
                    int len = (object as MathChannel).variable_names.length;
                    for (int i = 0; i < len; i++) {
                        Cld.Object obj;
                        string name  = (object as MathChannel).variable_names [i];
                        foreach (string id in objects.keys) {
                            obj = get_object (id);
                            if (name.contains (id) && (objects.get (id) is DataSeries)) {
                                (((obj as DataSeries).channel) as ScalableChannel).new_value.connect ((id, val) => {
                                double num = (object as MathChannel).calculated_value;
                            });

                            } else if (name == id && (objects.get (id) is ScalableChannel)) {
                                obj = get_object (id);
                                (obj as ScalableChannel).new_value.connect ((id, val) => {
                                    double num = (object as MathChannel).calculated_value;
                                });
                            } else {
                                obj = null;
                            }
                            if (obj != null) {
                                (object as MathChannel).add_object (id, obj);
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
                        (object as VChannel).add_channel( name, (get_object (name) as AIChannel));
                    }
                }
            }

            /* Setup the channel references for all of the log columns. */
            if (object is Cld.CsvLog) {
                foreach (var column in (object as Container).objects.values) {
                    if (column is Column) {
                        ref_id = (column as Column).chref;
                        if (ref_id != null) {
                            var channel = get_object (ref_id);
                            if (channel != null && channel is Channel) {
                                Cld.debug ("Assigning channel %s to column %s", channel.id, column.id);
                                (column as Column).channel = (channel as Channel);
                            }
                        }
                    }
                }

                /* Following the setup of the log columns, the log needs to attach the signals. */
                (object as Cld.CsvLog).connect_signals ();
            }

            /* Setup port references for all of the modules */
            if (object is Module) {
                ref_id = (object as Module).portref;
                Cld.debug ("Assigning Port %s to Module %s", ref_id, object.id);
                if (ref_id != null) {
                    var port = get_object (ref_id);
                    if (port != null && port is Port)
                        (object as Module).port = (port as Port);
                }
                ref_id = (object as Module).devref;
                if (ref_id != null && object is LicorModule)
                    /* set the virtual channel that are to be referenced by this module */
                    foreach (var licor_channel in channels.values) {
                        if ((licor_channel as Channel).devref == ref_id) {
                            Cld.debug ("Assigning Channel %s to Device %s", licor_channel.id,
                                        (object as LicorModule).devref);
                            (object as LicorModule).add_channel (licor_channel);
                        }
                    }
            }

            /* A  data series references a scalable channel. */
            if (object is DataSeries) {
                ref_id = (object as DataSeries).chanref;
                Cld.debug ("Assigning Channel %s to DataSeries %s", ref_id, object.id);
                (object as DataSeries).channel = get_object (ref_id) as ScalableChannel;
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
                                    var channel = get_object (ref_id);
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
                                    var dataseries = get_object (ref_id);
                                    if (dataseries != null && dataseries is DataSeries) {
                                        (process_value as ProcessValue2).dataseries
                                            = (dataseries as DataSeries);
                                        var chanref = (dataseries as DataSeries).chanref;
                                        (process_value as ProcessValue2).dataseries.channel = get_object (chanref)
                                                                                    as ScalableChannel;
       //                                 Cld.debug ("Pid2: %s ProcessValue2: %s mv: %s pv: %s mv channel: %s pv channel: %s>>>>>>>>>>>>>",
       //                                     (control_object as Pid2).id,
       //                                     process_value.id,
       //                                     (((control_object as Pid2).mv) as DataSeries).id,
       //                                     (((control_object as Pid2).pv) as DataSeries).id,
       //                                     (((control_object as Pid2).mv) as DataSeries).channel.id,
       //                                     (((control_object as Pid2).pv) as DataSeries).channel.id);
                                    }
                                }
                            }
                        }
                        ref_id = (control_object as Pid2).sp_chanref;
                        if (ref_id != null) {
                            var channel = get_object (ref_id);
                            if (channel != null && channel is ScalableChannel) {
                                Cld.debug ("Assigning ScalableChannel %s to Pid2 %s", ref_id, control_object.id);
                                (control_object as Pid2).sp_channel = channel as ScalableChannel;
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
        foreach (var object in objects.values) {
            Cld.debug ("%s", object.id);
        }
    }
    /**
     * Set a channel list for a Comedi task.
     **/
     public void set_channels (ComediTask task) {
        /* Get all of the channels */
        /* Build a channel list for this task. */
        foreach (var task_channel in channels.values) {
            if (((task_channel as Channel).taskref == (task as ComediTask).id) &&
                    ((task_channel as Channel).devref == (task as ComediTask).devref)) {
                (task as ComediTask).add_channel (task_channel);
            }
        }
     }

    /**
     * {@inheritDoc}
     */
    public override void update_objects (Gee.Map<string, Cld.Object> val) {
        _objects = val;
    }

    /**
     * {@inheritDoc}
     */
    public override string to_string () {
        int i;
        string str_data;

        str_data = "CldBuilder\n";
        for (i = 0; i < 80; i++)
            str_data += "-";
        str_data += "\n";

        foreach (var object in objects.values) {
            str_data += "%s\n".printf (object.to_string ());
        }

        for (i = 0; i < 80; i++)
            str_data += "-";
        str_data += "\n";

        return str_data;
    }
}
