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
 * Class use to use as an interface to the library.
 *
 * XXX some of this may not make sense functioning as a buildable object but
 * until more separation is made between those and other library objects
 * the id and to_string will stay and just be ignored.
 */
public class Cld.Context : Cld.AbstractContainer {

    /**
     * {@inheritDoc}
     */
    private Gee.Map<string, Cld.Object> _objects;
    public override Gee.Map<string, Cld.Object> objects {
        get { return (_objects); }
        set { update_objects (value); }
    }

    private Cld.LogController log_controller;
    private Cld.AcquisitionController acquisition_controller;
    private Cld.AutomationController automation_controller;

    construct {
        //_objects = new Gee.TreeMap<string, Cld.Object> ();
    }

    /**
     * Default construction.
     */
    public Context () {
    }

    public Context.from_config (Cld.XmlConfig xml) {
        var builder = new Cld.Builder.from_xml_config (xml);
        objects = builder.objects;
    }

    /**
     * Destruction.
     *
     * XXX not even sure if this is necessary or if a Gee.Map will clear itself
     */
    ~Context () {
        if (_objects != null)
            _objects.clear ();
    }

    /**
     * Connects all object signals where a reference has been requested.
     *
     * XXX not sure if this should actually happen here, or in builder
     */
    public void connect_signals () {
        /*
         *log_controller.request.connect ();
         *acquisition_controller.request.connect ();
         *automation_controller.request.connect ();
         */
    }

    /**
     * Generate refererences to between objects as needed.
     */
    public void generate () {

        string ref_id;
        if (objects == null) {
            return;
        }

        var channel_map = get_object_map (typeof (Cld.Channel));

        foreach (var object in objects.values) {
            /* Setup the device references for all of the channel types */
            if (object is Channel) {
                ref_id = (object as Channel).devref;
                if (ref_id != null) {
                    Cld.debug ("Assigning Device %s to Channel %s", ref_id, object.id);
                    var device = get_object (ref_id);
                    if (device != null && device is Device) {
                        (object as Channel).device = (device as Device);
                        try {
                            ref_id = (object as Channel).taskref;
                        } catch (Cld.Error.NULL_REF e) {
                            Cld.error ("%s", e.message);
                        }
                        Cld.debug ("Assigning Task %s to Channel %s", ref_id, object.id);
                        var task = (device as Cld.Container).get_object (ref_id);
                        if (task != null && task is Task)
                            (object as Channel).task = (task as Task);
                    }
                }
            }

            /* Channels with a calibration reference */
            if (object is Cld.ScalableChannel) {
                ref_id = (object as Cld.ScalableChannel).calref;
                Cld.debug ("Assigning Calibration %s to ScalableChannel %s", ref_id, object.id);
                if (ref_id != null) {
                    var calibration = get_object (ref_id);
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
                        foreach (string id in objects.keys) {
                            obj = get_object (id);
                            if (name.contains (id) && (objects.get (id) is DataSeries)) {
                                (((obj as DataSeries).channel) as Cld.ScalableChannel).new_value.connect ((id, val) => {
                                double num = (object as Cld.MathChannel).calculated_value;
                            });

                            } else if (name == id && (objects.get (id) is Cld.ScalableChannel)) {
                                obj = get_object (id);
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
                    foreach (var name in (object as VChannel).channel_names) {
                        (object as VChannel).add_channel (name, (get_object (name) as AIChannel));
                    }
                }
            }

            /* Setup the channel references for all of the log columns. */
            if (object is Cld.Log) {
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
                (object as Cld.Log).connect_signals ();

                /* Add a FIFO buffer to the Log for data from each ComediTask. */
                add_fifos (object as Cld.Log);
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
                    var chan0 = get_object ("heidolph00");
                    var chan1 = get_object ("heidolph01");
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
                ref_id = (object as DataSeries).chanref;
                Cld.debug ("Assigning Channel %s to DataSeries %s", ref_id, object.id);
                (object as DataSeries).channel = get_object (ref_id) as Cld.ScalableChannel;
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
                                                                                    as Cld.ScalableChannel;
                                    }
                                }
                            }
                        }
                        ref_id = (control_object as Pid2).sp_chanref;
                        if (ref_id != null) {
                            var channel = get_object (ref_id);
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
        var channel_map = get_object_map (typeof (Cld.Channel));

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
        var daq_map = get_object_map (typeof (Cld.Daq));

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
        return base.to_string ();
    }
}
