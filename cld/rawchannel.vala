/**
 * libcld
 * Copyright (c) 2016, Geoff Johnson, All rights reserved.
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
  * This channel class stores its raw value as an unsigned integer the length of
  * which is configurable as 8, 16, 32 or 64 bits. It can be used to hold the
  * value of a counter or a DIO port, for example.
  *
  */
public class Cld.RawChannel : Cld.AbstractChannel, Cld.Channel, Cld.ScalableChannel {

    /**
     * Property backing fields.
     */
    private GLib.Variant _raw_value;
    private double _scaled_value;
    private Cld.Calibration _calibration = null;

    /**
     * {@inheritDoc}
     */
    [Description(nick="Calibration Reference", blurb="The URI of the calibration")]
    public virtual string calref { get; set; }

    /**
     * {@inheritDoc}
     */
    [Description(nick="Calibration", blurb="The calibration used to generate a scaled value")]
    public virtual Cld.Calibration calibration {
        get {
            if (_calibration == null) {
                var calibrations = get_children (typeof (Cld.Calibration));
                foreach (var cal in calibrations.values) {
                    _calibration  = cal as Cld.Calibration;
                }
            }

            return _calibration;
        }
        set {
            objects.unset_all (get_children (typeof (Cld.Calibration))) ;
            objects.set (value.id, value);
            _calibration = null;
        }
    }

    /**
     * The word value of the channel (8, 16, 32 or 64 bit length)
     */
    public GLib.Variant raw_value {
        get { return _raw_value; }
        set {
            if (check_type (value)) {
                _raw_value = value;
                scaled_value = calibration.apply ((double)(value.get_uint32 ()));
            }
        }
    }

    /**
     * {@inheritDoc}
     */
    public virtual double scaled_value {
        get { return _scaled_value; }
        private set {
            _scaled_value = value;
            new_value (id, value);
        }
    }

    /**
     * Default construction.
     */
    public RawChannel () {
        set_num (0);
        this.tag = "WORD0";
        this.desc = "Word InputChannel";

        connect_signals ();
    }

    /**
     * Construction using XML
     */
    public RawChannel.from_xml_node (Xml.Node *node) {
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
    protected virtual void build_from_node (Xml.Node *node) throws GLib.Error {
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
                    case "tag":
                        tag = iter->get_content ();
                        break;
                    case "desc":
                        desc = iter->get_content ();
                        break;
                    case "num":
                        var val = iter->get_content ();
                        set_num (int.parse (val));
                        break;
                    case "calref":
                        calref = iter->get_content ();
                        break;
                    case "alias":
                        alias = iter->get_content ();
                        break;
                    case "data-type":
                        set_type (iter->get_content ());
                        message ("value is a %s", get_type_string ());
                        break;
                    default:
                        break;
                }
            }
        }
    }

    /**
     * Connect all the notify signals that are used to keep the backend XML
     * current.
     */
    private void connect_signals () {
        notify["tag"].connect ((s, p) => {
            debug ("Property %s changed for %s", p.get_name (), uri);
            update_node ();
        });

        notify["desc"].connect ((s, p) => {
            debug ("Property %s changed for %s", p.get_name (), uri);
            update_node ();
        });

        notify["num"].connect ((s, p) => {
            debug ("Property %s changed for %s", p.get_name (), uri);
            update_node ();
        });

        notify["alias"].connect ((s, p) => {
            debug ("Property %s changed for %s", p.get_name (), uri);
            update_node ();
        });
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
                    case "tag":
                        iter->set_content (tag);
                        break;
                    case "desc":
                        iter->set_content (desc);
                        break;
                    case "num":
                        iter->set_content (num.to_string ());
                        break;
                    case "alias":
                        iter->set_content (alias);
                        break;
                    case "calref":
                        iter->set_content (calref);
                        break;
                    case "data-type":
                        iter->set_content (get_type_string ());
                        break;
                    default:
                        break;
                }
            }
        }
    }

    /**
     * Constrains the raw value to one of four types
     */
    protected void set_type (string keyword) {
        switch (keyword) {
            case "byte"  :
                raw_value = new GLib.Variant.byte (0);
                break;
            case "uint8" :
                raw_value = new GLib.Variant.byte (0);
                break;
            case "uint16":
                raw_value = new GLib.Variant.uint16 (0);
                break;
            case "uint32":
                raw_value = new GLib.Variant.uint32 (0);
                break;
            case "uint64":
                raw_value = new GLib.Variant.uint64 (0);
                break;
            default:
                raw_value = new GLib.Variant.uint64 (0);
                break;
        }
    }

    /**
     * Test that a value is one of the four required types
     */
    protected bool check_type (GLib.Variant value) {
        bool result = false;
        var type = value.get_type ();
        GLib.VariantType[] items = { GLib.VariantType.BYTE,
                                     GLib.VariantType.UINT16,
                                     GLib.VariantType.UINT32,
                                     GLib.VariantType.UINT64 };
        Gee.List<GLib.VariantType> list =
                         new Gee.ArrayList<GLib.VariantType>.wrap (items, null);

        foreach (var t in list)
            if (t.equal (type))
                return true;

        warning ("Invalid data type");

        return result;
    }

    /**
      * @return The keyword name of the the raw data type
      */
    private string get_type_string () {
        GLib.VariantType type = raw_value.get_type ();
        if (type == GLib.VariantType.BYTE)
            return "byte";
        else if (type == GLib.VariantType.UINT16)
            return "uint16";
        else if (type == GLib.VariantType.UINT32)
            return "uint32";
        else if (type == GLib.VariantType.UINT64)
            return "uint64";
        else
            return "none";
    }

    /**
     * {@inheritDoc}
     **/
    public override void set_object_property (string name, Cld.Object object) {
        switch (name) {
            case "calibration":
                if (object is Cld.Calibration) {
                    calibration = object as Cld.Calibration;
                    calref = (object as Cld.Calibration).uri;
                    //message ("Calibration for %s changed to %s", uri, calibration.uri);
                }
                break;
            default:
                break;
        }
    }
}
