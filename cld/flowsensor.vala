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

public class Cld.FlowSensor : Cld.AbstractSensor {

    /* Property backing fields */

    private string _xml = """
      <cld:object id="fs0" type="sensor" sensor-type="flow">
        <cld:property name="channel-ref">cld://daqctl0/ai0</cld:property>
        <cld:property name="threshold-sp">100.0</cld:property>
      </cld:object>
    """;

    private string _xsd = """
      <xs:element name="object">
        <xs:attribute name="id" type="xs:string" use="required"/>
        <xs:attribute name="type" type="xs:string" use="required"/>
        <xs:attribute name="sensor-type" type="xs:string" use="required"/>
        <xs:attribute name="ref" type="xs:string" use="required"/>
        <!-- FIXME: This is missing the simple type properties. -->
      </xs:element>
    """;

    /* Properties */

    /**
     * {@inheritDoc}
     */
    protected override string xml {
        get { return _xml; }
    }

    /**
     * {@inheritDoc}
     */
    protected override string xsd {
        get { return _xsd; }
    }

    private weak Cld.ScalableChannel? _channel = null;

    /**
     * {@inheritDoc}
     */
    public Cld.ScalableChannel channel {
        get {
            if (_channel == null) {
                var channels = get_children (typeof (Cld.ScalableChannel));
                foreach (var chan in channels.values) {
                    _channel = chan as Cld.ScalableChannel;
                }
            }
            return _channel;
        }
        set {
            objects.unset_all (get_children (typeof (Cld.ScalableChannel)));
            objects.set (value.id, value);
        }
    }

    public double value {
        get {
            double tmp = -1.0;
            //var channel = (channel_ref != null) ? get_object_from_uri (channel_ref) as Cld.Channel : null;
            if (channel != null)
                tmp = (channel as Cld.ScalableChannel).scaled_value;
            return tmp;
        }
    }

    /**
     * Default construction.
     */
    public FlowSensor () {
        id = "fs0";
        threshold_sp = double.NAN;
        threshold_alarm_state = false;

        connect_signals ();
    }

    /**
     * Construction using an XML node
     */
    public FlowSensor.from_xml_node (Xml.Node *node) {
        this.node = node;

        try {
            build_from_node (node);
        } catch (GLib.Error e) {
            critical (e.message);
        }

        connect_signals ();
    }

    /**
     * {@inheritDoc}
     */
    protected override void build_from_node (Xml.Node *node) throws GLib.Error {
        /* Assuming that node type is valid */
        if (node->children == null)
            throw new Cld.ConfigurationError.EMPTY_NODESET (
                    "Configuration nodeset received is empty"
                );

        /* Read in the attributes */
        id = node->get_prop ("id");

        /* Read in the property/class element nodes */
        for (Xml.Node *iter = node->children; iter != null; iter = iter->next) {
            if (iter->name == "property") {
                switch (iter->get_prop ("name")) {
                    case "channel-ref":
                        channel_ref = iter->get_content ();
                        break;
                    case "threshold-sp":
                        var val = iter->get_content ();
                        threshold_sp = double.parse (val);
                        break;
                    case "threshold-tolerance":
                        var val = iter->get_content ();
                        threshold_tolerance = double.parse (val);
                        break;
                    default:
                        break;
                }
            }
        }
    }

    /**
     * {@inheritDoc}
     */
    public override void connect_signals () {
        var type = typeof (Cld.FlowSensor);
        ObjectClass ocl = (ObjectClass)type.class_ref ();

        foreach (var spec in ocl.list_properties ()) {
            notify[spec.get_name ()].connect ((s, p) => {
                debug ("Property %s changed for %s", p.get_name (), uri);
                if (node != null)
                    update_node ();
            });
        }

        var channel = (channel_ref != null) ? get_object_from_uri (channel_ref) as Cld.ScalableChannel : null;
        if (channel != null) {
            (channel as Cld.ScalableChannel).new_value.connect ((id, value) => {
                if ((Math.fabs (value - threshold_sp)) <
                              (Math.fabs(threshold_tolerance * threshold_sp))) {
                    if (threshold_alarm_state == false) {
                        threshold_alarm (id, value);
                    }
                 threshold_alarm_state = true;
                } else {
                    threshold_alarm_state = false;
                }
                debug ("alarm state: %s diff: %.3f thresh: %.3f",
                                threshold_alarm_state.to_string(),
                                Math.fabs (value - threshold_sp),
                                Math.fabs (threshold_tolerance * threshold_sp));
            });
        }
    }

    /**
     * Update the node data from this object.
     *
     * FIXME: This should be enforced through an interface, eg. Cld.Configurable.
     */
    private void update_node () {
        for (Xml.Node *iter = node->children; iter != null; iter = iter->next) {
            if (iter->name == "property") {
                switch (iter->get_prop ("name")) {
                    case "channel-ref":
                        debug ("Updating channel reference to: %s", channel_ref);
                        iter->set_content (channel_ref);
                        break;
                    case "threshold-sp":
                        debug ("Updating threshold SP to: %s", threshold_sp.to_string ());
                        iter->set_content (threshold_sp.to_string ());
                        break;
                    default:
                        break;
                }
            }
        }
    }
}
