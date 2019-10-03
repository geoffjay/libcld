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
 * Process value object for use with control objects, typically associated with
 * input and output measurements.
 */
public class Cld.ProcessValue : Cld.AbstractContainer {

    /**
     * ID reference of the channel associated with this process value.
     */
    public string chref { get; set; }

    /**
     * Read only property for the type (direction) of channel that the process
     * value represents, input is a process measurement, output is a
     * manipulated variable.
     */
    private Cld.ProcessValue.Type _chtype;
    [Description(nick="Channel Type", blurb="")]
    public Cld.ProcessValue.Type chtype {
        get {
            if (channel is Cld.IChannel)
                _chtype = Type.INPUT;
            else if (channel is Cld.OChannel)
                _chtype = Type.OUTPUT;
            else
                _chtype = Type.INVALID;
            return _chtype;
        }
    }

    /**
     * Referenced channel to use.
     */
    [Description(nick="Channel", blurb="")]
    public weak Cld.Channel channel {
        get {
            var channels = get_children (typeof (Cld.Channel));
            foreach (var chan in channels.values) {

                /* this should only happen once */
                return chan as Cld.Channel;
            }

        return null;
        }
        set {
            objects.unset_all (get_children (typeof (Cld.Channel))) ;
            objects.set (value.id, value);
        }
    }

    /**
     * Type options to use for channel direction.
     */
    public enum Type {
        INPUT = 0,
        OUTPUT,
        INVALID;

        public string to_string () {
            switch (this) {
                case INPUT:   return "Input";
                case OUTPUT:  return "Output";
                case INVALID: return "Invalid";
                default:      assert_not_reached ();
            }
        }
    }

    /* constructor */
    public ProcessValue () {
        id = "pv0";
        chref = "ch0";
    }

    public ProcessValue.full (string id, Channel channel) {
        this.id = id;
        this.chref = channel.id;
        this.channel = channel;
    }

    public ProcessValue.from_xml_node (Xml.Node *node) {
        if (node->type == Xml.ElementType.ELEMENT_NODE &&
            node->type != Xml.ElementType.COMMENT_NODE) {
            id = node->get_prop ("id");
            chref = node->get_prop ("chref");
        }
    }
}

/**
 * Process value object for use with control objects, typically associated with
 * input and output measurements.
 */
public class Cld.ProcessValue2 : Cld.AbstractContainer {

    /**
     * Read only property for the type (direction) of channel that the process
     * value represents, input is a process measurement, output is a
     * manipulated variable.
     */
    private Cld.ProcessValue2.Type _chtype;
    [Description(nick="Channel Type", blurb="")]
    public Cld.ProcessValue2.Type chtype {
        get { return _chtype; }
    }

    /**
     * ID reference of the dataseries associated with this process value.
     */
    [Description(nick="Reference", blurb="")]
    public string dsref;

    /**
     * Referenced dataseries to use.
     */
    [Description(nick="Data Series", blurb="The referenced dataseries")]
    public weak Cld.DataSeries dataseries {
        get {
            var dschildren = get_children (typeof (Cld.DataSeries));
            foreach (var ds in dschildren.values) {

                /* this should only happen once */
                return ds as Cld.DataSeries;
            }

        return null;
        }
        set {
            objects.unset_all (get_children (typeof (Cld.DataSeries))) ;
            objects.set (value.id, value);
        }
    }

    /**
     * Type options to use for channel direction.
     */
    public enum Type {
        INPUT = 0,
        OUTPUT,
        INVALID;

        public string to_string () {
            switch (this) {
                case INPUT:   return "Input";
                case OUTPUT:  return "Output";
                case INVALID: return "Invalid";
                default:      assert_not_reached ();
            }
        }
    }

    /* constructor */
    public ProcessValue2 () {
        id = "pv0";
        dsref = "ds0";
    }

    public ProcessValue2.full (string id, DataSeries dataseries) {
        this.id = id;
        this.dsref = dataseries.id;
        this.dataseries = dataseries;
    }

    /**
     * Alternate construction that uses an XML node to set the object up.
     *
     * Example XML code:
     * {{{
     *   <cld:object id="pv0" type="process_value2" dsref="/ds00" direction="input"/>
     * }}}
     * @param node and {@link Xml.Node}
     * @see Cld.Control
     */
    public ProcessValue2.from_xml_node (Xml.Node *node) {
        if (node->type == Xml.ElementType.ELEMENT_NODE &&
            node->type != Xml.ElementType.COMMENT_NODE) {
            id = node->get_prop ("id");
            dsref = node->get_prop ("dsref");
            string direction = node->get_prop ("direction");
            if (direction == "input") {
                _chtype = Type.INPUT;
            } else if (direction == "output") {
                _chtype = Type.OUTPUT;
            } else {
                _chtype = Type.INVALID;
            }
        }
    }
}

/**
 * Control object to calculate an output process value.
 */
public class Cld.Control : Cld.AbstractContainer {

    /**
     * Default construction.
     */
    public Control () {
        id = "ctl0";
        objects = new Gee.TreeMap<string, Cld.Object> ();
    }

    /**
     * Alternate construction that uses an XML node to set the object up.
     *
     * Example XML code:
     * {{{
     * <cld:object id="FD1P1" type="pid-2">
     *   <cld:property name="desc">PID00</cld:property>
     *   <cld:property name="dt">100</cld:property>
     *   <cld:property name="sp">46.5</cld:property>
     *   <cld:property name="kp">0</cld:property>
     *   <cld:property name="ki">0.10000000000000001</cld:property>
     *   <cld:property name="kd">0</cld:property>
     *   <cld:object id="pv0" type="process_value2" dsref="/ds00" direction="input"/>
     *   <cld:object id="pv1" type="process_value2" dsref="/ds01" direction="output"/>
     * </cld:object>
     * }}}
     * @param node and {@link Xml.Node}
     * @see ProcessValue2
     */
    public Control.from_xml_node (Xml.Node *node) {
        objects = new Gee.TreeMap<string, Cld.Object> ();

        if (node->type == Xml.ElementType.ELEMENT_NODE &&
            node->type != Xml.ElementType.COMMENT_NODE) {
            id = node->get_prop ("id");
            /* iterate through node children */
            for (Xml.Node *iter = node->children;
                 iter != null;
                 iter = iter->next) {
                if (iter->name == "property") {
                    /* no defined properties yet */
                    switch (iter->get_prop ("name")) {
                        default:
                            break;
                    }
                } else if (iter->name == "object") {
                    var type = iter->get_prop ("type");
                    switch (type) {
                        case "pid":
                            var pid = new Cld.Pid.from_xml_node (iter);
                            add (pid);
                            break;
                        case "pid-2":
                            var pid = new Cld.Pid2.from_xml_node (iter);
                            add (pid);
                            break;
                        default:
                            break;
                    }
                }
            }
        }
    }

    ~Control () {
        if (objects != null)
            objects.clear ();
    }

//    /**
//     * {@inheritDoc}
//     */
//    public override string to_string () {
//        string str_data = "[%s] : Control object\n".printf (id);
//        if (!objects.is_empty) {
//            foreach (var dev in objects.values)
//                str_data += "  %s".printf (dev.to_string ());
//        }
//        return str_data;
//    }
}
