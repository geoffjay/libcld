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
 * Perhaps not the most accurate naming here, this object represents a set
 * of coefficients used to scale a process value from a raw measurement to
 * a real life measurement such as LPM, MPH, etc.
 *
 * Calculation should be performed using the index value to determine the
 * exponent, eg. for a linear scale + offset
 *
 *   y = a[0]*x^0 + a[1]*x^1
 */
public class Cld.Calibration : AbstractObject, Container {

    /* property backing fields */
    private Gee.Map<string, Object> _objects;

    /* properties */
    public string units       { get; set; }
    public override string id { get; set; }

    /* needs to be a map instead of a list to allow for gaps in the list */
    public Gee.Map<string, Object> objects {
        get { return (_objects); }
        set { update_objects (value); }
    }

    /* constructor */
    public Calibration () {
        /* set defaults */
        units = "Volts";
        id = "cal0";
        objects = new Gee.TreeMap<string, Object> ();
    }

    public Calibration.with_units (string units) {
        /* instantiate object */
        GLib.Object (units: units);
        id = "cal0";
        objects = new Gee.TreeMap<string, Object> ();
    }

    public Calibration.from_xml_node (Xml.Node *node) {
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
                        case "units":
                            units = iter->get_content ();
                            break;
                        default:
                            break;
                    }
                } else if (iter->name == "object") {
                    if (iter->get_prop ("type") == "coefficient") {
                        var coeff = new Coefficient.from_xml_node (iter);
                        objects.set (coeff.id, coeff);
                    }
                }
            }
        }
    }

    public int coefficient_count () {
        return objects.size;
    }

    public Coefficient nth_coefficient (int index) {
        foreach (var coefficient in objects.values) {
            if ((coefficient as Coefficient).n == index)
                return coefficient as Coefficient;
        }
        /* if we made it here the index requested doesn't exist */
        throw new Cld.CalibrationError.KEY_NOT_FOUND ("The selected value does not exist");
    }

    public void set_nth_coefficient (int index, double val) {
        foreach (var coefficient in objects.values) {
            if ((coefficient as Coefficient).n == index)
                objects.unset (coefficient.id);
        }

        /* either it didn't exist or we dropped it */
        var c = new Coefficient ();
        c.n = index;
        c.value = val;
        objects.set (c.id, c);
    }

    public void set_coefficient (string id, Coefficient coefficient) {
        if (objects.has_key (id))
            objects.unset (id);
        objects.set (id, coefficient);
    }

    public Coefficient? get_coefficient (int index) {
        foreach (var coefficient in objects.values) {
            if ((coefficient as Coefficient).n == index)
                return coefficient as Coefficient;
        }
        return null;
    }

    public void add_coefficient (int index, double val) {
        foreach (var coefficient in objects.values) {
            if ((coefficient as Coefficient).n == index)
                objects.unset (coefficient.id);
        }

        /* either it didn't exist or we dropped it */
        var c = new Coefficient ();
        c.n = index;
        c.value = val;
        objects.set (c.id, c);
    }

    /**
     * Redundant method to return the list of objects that represent the
     * calibration coefficients.
     */
    public Gee.Map<string, Object> get_coefficients () {
        return _objects;
    }

    /**
     * Sets the calibration objects to be what's required for voltage
     * output - a slope of 1 and y intercept of 0.
     */
    public void set_default () {
        add_coefficient (0, 0.0);
        add_coefficient (1, 1.0);
    }

    /**
     * Update property backing field for objects list.
     *
     * @param event Array list to update property variable
     */
    private void update_objects (Gee.Map<string, Object> val) {
        _objects = val;
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
     * Print the contents of the Calibration including any items in its
     * coefficient list.
     */
    public override string to_string () {
        string str_data = "[%s] : y = ".printf (id);
        foreach (var coefficient in objects.values) {
            str_data += "%s".printf (coefficient.to_string ());
        }
        return str_data;
    }
}
