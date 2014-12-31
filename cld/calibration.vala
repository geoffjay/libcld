/**
 * libcld
 * Copyright (c) 2014, Geoff Johnson, All rights reserved.
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
 * Perhaps not the most accurate naming here, this object represents a set
 * of coefficients used to scale a process value from a raw measurement to
 * a real life measurement such as LPM, MPH, etc.
 *
 * Calculation should be performed using the index value to determine the
 * exponent, eg. for a linear scale + offset
 *
 *   y = a[0]*x^0 + a[1]*x^1
 */
public class Cld.Calibration : Cld.AbstractContainer {

    private Gee.Map<string, Cld.Object>? _coefficients = null;
    public Gee.Map<string, Cld.Object> coefficients {
        get {
            if (_coefficients == null) {
                _coefficients = new Gee.TreeMap<string, Cld.Object> ();
                foreach (var object in objects.values) {
                    if (object is Cld.Coefficient)
                        _coefficients.set (object.id, object);
                }
            }
            return _coefficients;
        }
    }

    public string units { get; set; }

    /* constructor */
    public Calibration () {
        /* set defaults */
        units = "Volts";
        id = "cal0";
        _objects = new Gee.TreeMap<string, Cld.Object> ();
        /* set defaults */
        try {
            add (new Cld.Coefficient.with_data ("cft0", 0, 0.0));
            add (new Cld.Coefficient.with_data ("cft1", 1, 1.0));
        } catch (Cld.Error e) {
            critical (e.message);
        }
        connect_signals ();
    }

    public Calibration.with_units (string units) {
        /* instantiate object */
        this.units = units;
        id = "cal0";
        _objects = new Gee.TreeMap<string, Cld.Object> ();
        connect_signals ();
    }

    public Calibration.from_xml_node (Xml.Node *node) {
        _objects = new Gee.TreeMap<string, Cld.Object> ();
        this.node = node;

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
                        case "units":
                            units = iter->get_content ();
                            break;
                        default:
                            break;
                    }
                } else if (iter->name == "object") {
                    if (iter->get_prop ("type") == "coefficient") {
                        var coeff = new Cld.Coefficient.from_xml_node (iter);
                        coeff.parent = this;
                        try {
                            add (coeff);
                        } catch (Cld.Error e) {
                            critical (e.message);
                        }
                    }
                }
            }
        }
        connect_signals ();
    }

    ~Calibration () {
        if (_objects != null)
            _objects.clear ();
    }

    /**
     * Connect all the notify signals that should require the node to update
     */
    private void connect_signals () {
        notify["units"].connect ((s, p) => {
            message ("Property %s changed for %s", p.get_name (), uri);
            update_node ();
        });
    }

    /**
     * Update the XML Node for this object.
     */
    private void update_node () {
        if (node->type == Xml.ElementType.ELEMENT_NODE &&
            node->type != Xml.ElementType.COMMENT_NODE) {
            /* iterate through node children */
            for (Xml.Node *iter = node->children;
                 iter != null;
                 iter = iter->next) {
                if (iter->name == "property") {
                    switch (iter->get_prop ("name")) {
                        case "units":
                            iter->set_content (units);
                            break;
                        default:
                            break;
                    }
                }
            }
        }
    }

    public int coefficient_count () {
        return objects.size;
    }

    public Cld.Coefficient? nth_coefficient (int index) {
        foreach (var coefficient in objects.values) {
            if ((coefficient as Cld.Coefficient).n == index)
                return coefficient as Cld.Coefficient;
        }

        /* if we made it here the index requested doesn't exist */
        //throw new Cld.CalibrationError.KEY_NOT_FOUND (
        //        "The selected value does not exist"
        //    );

        return null;
    }

    public void set_nth_coefficient (int index, double val) {
        foreach (var coefficient in objects.values) {
            if ((coefficient as Cld.Coefficient).n == index)
                objects.unset (coefficient.id);
        }

        /* either it didn't exist or we dropped it */
        var c = new Cld.Coefficient ();
        c.n = index;
        c.value = val;
        try {
            add (c);
        } catch (Cld.Error e) {
            critical (e.message);
        }
    }

    public void set_coefficient (string id, Cld.Coefficient coefficient) {
        if (objects.has_key (id))
            objects.unset (id);
        objects.set (id, coefficient);
    }

    public Cld.Coefficient? get_coefficient (int index) {
        foreach (var coefficient in objects.values) {
            if ((coefficient as Cld.Coefficient).n == index)
                return coefficient as Cld.Coefficient;
        }
        return null;
    }

    public void add_coefficient (int index, double val) {
        foreach (var coefficient in objects.values) {
            if ((coefficient as Cld.Coefficient).n == index)
                objects.unset (coefficient.id);
        }

        /* either it didn't exist or we dropped it */
        var c = new Cld.Coefficient ();
        c.n = index;
        c.value = val;
        try {
            add (c);
        } catch (Cld.Error e) {
            critical (e.message);
        }
    }

    /**
     * Sets the calibration objects to be what's required for voltage
     * output - a slope of 1 and y intercept of 0.
     */
    public void set_default () {
        Coefficient coefficient;

        coefficient = get_coefficient (0);
        coefficient.value = 0.0;
        set_coefficient (coefficient.id, coefficient);
        coefficient = get_coefficient (1);
        coefficient.value = 1.0;
        set_coefficient (coefficient.id, coefficient);
    }

    /**
     * Apply the calibration coefficients to the measurement value passed in.
     *
     * @param value Process measurement to apply the calibration/scale to
     * @return Result of the calibration/scale calculation
     */
    public double apply (double value) {
        double result = 0.0;

        foreach (var coefficient in objects.values) {
            if ((coefficient as Cld.Coefficient).n == 0) {
                result += (coefficient as Cld.Coefficient).value;
            } else if ((coefficient as Coefficient).n == 1) {
                result += value * (coefficient as Cld.Coefficient).value;
            } else {
                result += Math.pow (value, (coefficient as Cld.Coefficient).n)
                            * (coefficient as Cld.Coefficient).value;
            }
        }
        return result;
    }

//    /**
//     * {@inheritDoc}
//     */
//    public override string to_string () {
//        string str_data = "[%s] : y = ".printf (id);
//        foreach (var coefficient in objects.values) {
//            str_data += "%s".printf (coefficient.to_string ());
//        }
//        return str_data;
//    }
}
