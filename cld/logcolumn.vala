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
 * Column class to reference channels to log.
 */
public class Cld.Column : Cld.AbstractContainer {

    /**
     * ID reference of the channel associated with this column.
     */
    public string chref { get; set; }

    /**
     * Referenced channel to use.
     */
    public Cld.Channel channel {
        get {
            var channels = get_children (typeof (Cld.Channel));
            foreach (var chan in channels.values) {
                return chan as Cld.Channel;
            }

            return null;
        }
        set {
            objects.unset_all (get_children (typeof (Cld.Channel)));
            objects.set (value.id, value);
        }
    }

    /**
     * Channel value for tracking.
     */
    private double _channel_value;
    public double channel_value {
        get { return _channel_value; }
        set { _channel_value = value; }
    }

    /**
     * Default constructor.
     */
    public Column () {
        id = "col0";
        chref = "ch0";
    }

    public Column.from_xml_node (Xml.Node *node) {
        if (node->type == Xml.ElementType.ELEMENT_NODE &&
            node->type != Xml.ElementType.COMMENT_NODE) {
            id = node->get_prop ("id");
            chref = node->get_prop ("chref");
        }
    }
}
