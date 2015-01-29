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

using Cld;

public class FlowSensorTests : SensorTests {

    string xml = """
        <object id="fs0"
                type="sensor"
                sensor-type="flow"
                ref="ai0">
            <property name="threshold-sp">100.0</property>
        </object>
    """;

    public FlowSensorTests () {
        base ("FlowSensor");
        add_test ("[FlowSensor] Test construction from XML node string", test_xml_construct);
        add_test ("[FlowSensor] Test backend array for value average property", test_property_edit);
    }

    public override void set_up () {
        test_object = new FlowSensor ();
    }

    public override void tear_down () {
        test_object = null;
    }

    private Xml.Node * get_node () {
        Xml.Doc *doc = Xml.Parser.parse_memory (xml, xml.length);
        Xml.XPath.Context *ctx = new Xml.XPath.Context (doc);
        Xml.XPath.Object *obj = ctx->eval_expression ("//object");
        Xml.Node *node = obj->nodesetval->item (0);

        return node;
    }

    private void test_xml_construct () {
        /* XXX doesn't seem inline with using set_up and test_object */
        var test_sensor = new FlowSensor.from_xml_node (get_node ());
        assert (test_sensor != null);
        assert ((test_sensor as Cld.Object).id == "fs0");
    }

    /**
     * XXX this is a useless test that was only added to test a property notify
     */
    private void test_property_edit () {
        var test_sensor = new FlowSensor.from_xml_node (get_node ());

        /* Check the Sensor exists */
        assert (test_sensor != null);

        test_sensor.threshold_sp = 150.0;
        assert (test_sensor.threshold_sp == 150.0);
    }
}
