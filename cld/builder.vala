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
public class Cld.Builder : GLib.Object {

    /**
     * The XML configuration to use for building
     */
    public XmlConfig xml { get; set; }

    private Gee.Map<string, Object> _objects;
    public Gee.Map<string, Object> objects {
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

    private Gee.Map<string, Object>? _calibrations = null;
    public Gee.Map<string, Object>? calibrations {
        get {
            if (_calibrations == null) {
                _calibrations = new Gee.TreeMap<string, Object> ();
                foreach (var object in objects.values) {
                    if (object is Calibration)
                        _calibrations.set (object.id, object);
                }
            }
            return _calibrations;
        }
    }

    private Gee.Map<string, Object>? _channels = null;
    public Gee.Map<string, Object>? channels {
        get {
            if (_channels == null) {
                _channels = new Gee.TreeMap<string, Object> ();
                foreach (var object in objects.values) {
                    if (object is Channel)
                        _channels.set (object.id, object);
                }
            }
            return _channels;
        }
    }

    private Gee.Map<string, Object>? _logs = null;
    public Gee.Map<string, Object>? logs {
        get {
            if (_logs == null) {
                _logs = new Gee.TreeMap<string, Object> ();
                foreach (var object in objects.values) {
                    if (object is Log)
                        _logs.set (object.id, object);
                }
            }
            return _logs;
        }
    }

    public Builder.from_file (string filename) {
        xml = new XmlConfig (filename);
        _objects = new Gee.TreeMap<string, Object> ();
        build_object_map ();
    }

    public Builder.from_xml_config (XmlConfig xml) {
        GLib.Object (xml: xml);
        _objects = new Gee.TreeMap<string, Object> ();
        build_object_map ();
    }

    /**
     * Add a object to the array list of objects
     *
     * @param object object object to add to the list
     */
    public void add (Object object) {
        objects.set (object.id, object);
    }

    /**
     * Update the internal object list.
     *
     * @param val List of objects to replace the existing one
     */
    public void update_objects (Gee.Map<string, Object> val) {
        _objects = val;
    }

    public void sort_objects () {
        Gee.List<Object> map_values = new Gee.ArrayList<Object> ();

        map_values.add_all (objects.values);
        map_values.sort ((GLib.CompareFunc) Object.compare);
        objects.clear ();
        foreach (Object object in map_values) {
            objects.set (object.id, object);
        }
    }

    /**
     * Search the object list for the object with the given ID
     *
     * @param id ID of the object to retrieve
     * @return The object if found, null otherwise
     */
    public Object? get_object (string id) {
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
     * build_object_map
     */
    private void build_object_map () {
        string type;
        string ctype;
        string direction;
        string xpath = "/cld/objects/object";

        /* request the nodeset from the configuration */
        Xml.XPath.NodeSet *nodes = xml.nodes_from_xpath (xpath);
        Xml.Node *node = nodes->item (0);

        for (Xml.Node *iter = node; iter != null; iter = iter->next) {
            if (iter->type == Xml.ElementType.ELEMENT_NODE &&
                iter->type != Xml.ElementType.COMMENT_NODE) {
                /* load all available objects */
                if (iter->name == "object") {
                    Object object;
                    type = iter->get_prop ("type");
                    switch (type) {
                        case "daq":
                            object = new Daq.from_xml_node (iter);
                            break;
                        case "log":
                            object = new Log.from_xml_node (iter);
                            break;
                        case "control":
                            object = new Control.from_xml_node (iter);
                            break;
                        case "calibration":
                            object = new Calibration.from_xml_node (iter);
                            break;
                        case "channel":
                            ctype = iter->get_prop ("ctype");
                            direction = iter->get_prop ("direction");
                            if (ctype == "analog" && direction == "input")
                                object = new AIChannel.from_xml_node (iter);
                            else if (ctype == "analog" &&
                                     direction == "output")
                                object = new AOChannel.from_xml_node (iter);
                            else if (ctype == "digital" &&
                                     direction == "input")
                                object = new DIChannel.from_xml_node (iter);
                            else if (ctype == "digital" &&
                                     direction == "output")
                                object = new DOChannel.from_xml_node (iter);
                            else if (ctype == "calculation" ||
                                     ctype == "virtual")
                                object = new VChannel.from_xml_node (iter);
                            else
                                object = null;
                            break;
                        default:
                            object = null;
                            break;
                    }
                    add (object);
                }
            }
        }
    }

    public virtual void print (FileStream f) {
        f.printf ("%s\n", to_string ());
    }

    public string to_string () {
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
