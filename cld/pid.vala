/**
 * Copyright (C) 2010 Geoff Johnson <geoff.jay@gmail.com>
 *
 * This file is part of libcld.
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
 */

public class Cld.Pid : AbstractObject {
    /* property backing fields */
    private Gee.Map<string, Object> _process_values;

    /* properties */
    [Property(nick = "ID", blurb = "PID ID")]
    public override string id { get; set; }

    [Property(nick = "Kp", blurb = "PID Kp Value")]
    public double kp { get; set; }

    [Property(nick = "Ki", blurb = "PID Ki Value")]
    public double ki { get; set; }

    [Property(nick = "Kd", blurb = "PID Kd Value")]
    public double kd { get; set; }

    [Property(nick = "SP", blurb = "PID Set Point Value")]
    public double sp { get; set; }

    [Property(nick = "P Error", blurb = "PID Proportional Gain Error")]
    public double p_err { get; set; }

    [Property(nick = "I Error", blurb = "PID Integral Gain Error")]
    public double i_err { get; set; }

    [Property(nick = "D Error", blurb = "PID Differential Gain Error")]
    public double d_err { get; set; }

    /* this needs to be a map instead of a list to allow for gaps in the list */
    public Gee.Map<string, Object> process_values {
        get { return (_process_values); }
        set { update_process_values (value); }
    }

    /**
     * Default constructor
     */
    public Pid (string id,
                double sp,
                double kp,
                double ki,
                double kd,
                double p_err = 0.0,
                double i_err = 0.0,
                double d_err = 0.0) {
        /* instantiate object */
        GLib.Object (id:    id,
                     sp:    sp,
                     kp:    kp,
                     ki:    ki,
                     kd:    kd,
                     p_err: p_err,
                     i_err: i_err,
                     d_err: d_err);

        process_values = new Gee.TreeMap<string, Object> ();
    }

    /**
     * Construction using an xml node
     */
    public Pid.from_xml_node (Xml.Node *node) {
        string value;

        process_values = new Gee.TreeMap<string, Object> ();

        if (node->type == Xml.ElementType.ELEMENT_NODE &&
            node->type != Xml.ElementType.COMMENT_NODE) {
            id = node->get_prop ("id");
            /* iterate through node children */
            for (Xml.Node *iter = node->children; iter != null; iter = iter->next) {
                if (iter->name == "property") {
                    switch (iter->get_prop ("name")) {
                        case "sp":
                            value = iter->get_content ();
                            sp = double.parse (value);
                            break;
                        case "kp":
                            value = iter->get_content ();
                            kp = double.parse (value);
                            break;
                        case "ki":
                            value = iter->get_content ();
                            ki = double.parse (value);
                            break;
                        case "kd":
                            value = iter->get_content ();
                            kd = double.parse (value);
                            break;
                        default:
                            break;
                    }
                } else if (iter->name == "object") {
                    if (iter->get_prop ("type") == "process_value") {
                        var pv = new ProcessValue.from_xml_node (iter);
                        process_values.set (pv.id, pv);
                    }
                }
            }
        }
    }

    /**
     * Update property backing field for process values list
     *
     * @param event Array list to update property variable
     */
    private void update_process_values (Gee.Map<string, Object> val) {
        _process_values = val;
    }

    public override string to_string () {
        string str_data  = "[%s] : PID Object:";
               str_data += "\tSP %.3f\n".printf (sp);
               str_data += "\tKp %.3f\n".printf (kp);
               str_data += "\tKi %.3f\n".printf (ki);
               str_data += "\tKd %.3f\n".printf (kd);
        /* add iteration to print process values later during testing */
        return str_data;
    }
}
