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

using Cld;

public class AIChannelTests : ChannelTests {

    public AIChannelTests () {
        base ("AIChannel");
        add_test ("[AIChannel] Test construction from XML node string", test_xml_construct);
        add_test ("[AIChannel] Test backend array for value average property", test_avg_value);
        add_test ("[AIChannel] Test backend array for measured values property", test_raw_value);
        add_test ("[AIChannel] Test backend array for scaled value property", test_scaled_value);
    }

    public override void set_up () {
        test_object = new AIChannel ();
    }

    public override void tear_down () {
        test_object = null;
    }

    private void test_xml_construct () {
        var xml = """
            <object id="ai0"
                    type="channel"
                    ref="dev0"
                    ctype="analog"
                    direction="input">
                <property name="tag">IN0</property>
                <property name="desc">Test Input</property>
                <property name="num">0</property>
                <property name="calref">cal0</property>
            </object>
        """;

        Xml.Doc *doc = Xml.Parser.parse_memory (xml, xml.length);
        Xml.XPath.Context *ctx = new Xml.XPath.Context (doc);
        Xml.XPath.Object *obj = ctx->eval_expression ("//object");
        Xml.Node *node = obj->nodesetval->item (0);

        /* XXX doesn't seem inline with using set_up and test_object */
        var test_channel = new AIChannel.from_xml_node (node);
        assert (test_channel.id == "ai0");
    }

    private void test_avg_value () {
        var test_channel = test_object as AIChannel;

        /* Check the Channel exists */
        assert (test_channel != null);

        //assert (test_channel.avg_value == 0.0);
        //test_channel.avg_value = 1.0;
        //assert (test_channel.avg_value == 1.0);
    }

    private void test_raw_value () {
        var test_channel = test_object as AIChannel;

        /* Check the Channel exists */
        assert (test_channel != null);

        assert (test_channel.raw_value == 0.0);
        test_channel.raw_value_list_size = 10;
        test_channel.add_raw_value (1.0);
        test_channel.add_raw_value (2.0);
        test_channel.add_raw_value (3.0);
        assert (test_channel.avg_value == 2.0);
    }

    private void test_scaled_value () {
        var test_channel = test_object as AIChannel;

        /* Check the Channel exists */
        assert (test_channel != null);

        Calibration cal = new Calibration ();
        test_channel.calibration = cal;

        test_channel.raw_value_list_size = 10;
        test_channel.add_raw_value (1.0);
        test_channel.add_raw_value (2.0);
        test_channel.add_raw_value (3.0);

        assert (test_channel.scaled_value == 2.0);
        Coefficient coefficient;
        coefficient = cal.get_coefficient (0);
        coefficient.value = 1.0;
        cal.set_coefficient (coefficient.id, coefficient);
        coefficient = cal.get_coefficient (1);
        coefficient.value = 2.0;
        cal.set_coefficient (coefficient.id, coefficient);
        assert (test_channel.scaled_value == 5.0);
    }
}
