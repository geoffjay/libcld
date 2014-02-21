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
 * Authors:
 *  Geoff Johnson <geoff.jay@gmail.com>
 *  Steve Roy <sroy1966@gmail.com>
 */

/**
 * Process value object for use with control objects, typically associated with
 * input and output measurements.
 */
public class Cld.ProcessValue : AbstractObject {

    /**
     * {@inheritDoc}
     */
    public override string id { get; set; }

    /**
     * ID reference of the channel associated with this process value.
     */
    public string chref { get; set; }

    /**
     * Read only property for the type (direction) of channel that the process
     * value represents, input is a process measurement, output is a
     * manipulated variable.
     */
    private int _chtype;
    public int chtype {
        get {
            if (channel is IChannel)
                _chtype = Type.INPUT;
            else if (channel is OChannel)
                _chtype = Type.OUTPUT;
            else
                _chtype = Type.INVALID;
            //stdout.printf ("[%s] Channel (%s) type: %d\n", id, chref, _chtype);
            return _chtype;
        }
    }

    /**
     * Referenced channel to use.
     */
    public weak Channel channel { get; set; }

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

    public override string to_string () {
        string str_data  = "[%s] : Process value\n".printf (id);
               str_data += "\tchref %s\n\n".printf (chref);
        return str_data;
    }
}

/**
 * Process value object for use with control objects, typically associated with
 * input and output measurements.
 */
public class Cld.ProcessValue2 : AbstractObject {

    /**
     * {@inheritDoc}
     */
    public override string id { get; set; }

    /**
     * Read only property for the type (direction) of channel that the process
     * value represents, input is a process measurement, output is a
     * manipulated variable.
     */
    private int _chtype;
    public int chtype {
        get { return _chtype; }
    }

    /**
     * ID reference of the dataseries associated with this process value.
     */
    public string dsref { get; set; }

    /**
     * Referenced dataseries to use.
     */
    public weak DataSeries dataseries { get; set; }

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
        dsref = "ch0";
    }

    public ProcessValue2.full (string id, DataSeries dataseries) {
        this.id = id;
        this.dsref = dataseries.id;
        this.dataseries = dataseries;
    }

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

    public override string to_string () {
        string str_data  = "[%s] : Process value\n".printf (id);
               str_data += "\tdsref %s\n\n".printf (dsref);
        return str_data;
    }
}

/**
 * Control object to calculate an output process value.
 */
public class Cld.Control : AbstractContainer {

    /**
     * {@inheritDoc}
     */
    public override string id { get; set; }

    private Gee.Map<string, Object> _objects;
    public override Gee.Map<string, Object> objects {
        get { return (_objects); }
        set { update_objects (value); }
    }

    /* constructor */
    public Control () {
        id = "ctl0";
        objects = new Gee.TreeMap<string, Object> ();
    }

    public Control.from_xml_node (Xml.Node *node) {
        objects = new Gee.TreeMap<string, Object> ();

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
                            var pid = new Pid.from_xml_node (iter);
                            objects.set (pid.id, pid);
                            break;
                        case "pid-2":
                            var pid = new Pid2.from_xml_node (iter);
                            objects.set (pid.id, pid);
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

    /**
     * {@inheritDoc}
     */
    public override void update_objects (Gee.Map<string, Object> val) {
        _objects = val;
    }

    /**
     * {@inheritDoc}
     */
    public override void add (Object object) {
        objects.set (object.id, object);
    }

    /**
     * {@inheritDoc}
     */
    public override Object? get_object (string id) {
        Object? result = null;

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
     * {@inheritDoc}
     */
    public override string to_string () {
        string str_data = "[%s] : Control object\n".printf (id);
        if (!objects.is_empty) {
            foreach (var dev in objects.values)
                str_data += "  %s".printf (dev.to_string ());
        }
        return str_data;
    }

    /**
     * Perform the control loop calculation.
     * XXX create an AbstractControl class and move this to it
     */
    //public abstract void update ();
}
