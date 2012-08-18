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
 * Analog input channel used with measurements and other control functions.
 */
public class Cld.AIChannel : AbstractChannel, Channel, AChannel, IChannel {
    /* properties - from Object */
    public override string id           { get; set; }
    /* properties - from Channel */
    public override int num             { get; set; }
    public override string devref       { get; set; }
    public override string tag          { get; set; }
    public override string desc         { get; set; }
    /* properties - from AChannel */
    public Calibration cal              { get; set; }
    public string calref                { get; set; }
    public double value                 { get; set; }
    public double scaled_value          { get; set; }
    public double avg_value             { get; set; }
    /* properties */
    public double slope                 { get; set; }
    public double yint                  { get; set; }
    public string units                 { get; set; }
    public string color                 { get; set; }
    public int raw_value_list_size      { get; set; }    /* redundant */

    public Gee.LinkedList<double?> raw_value_list;

    /* default constructor */
    public AIChannel (string id, string tag, string desc,
                      int num, double slope, double yint,
                      string units, string color) {
        /* fill with available parameters */
//        base (num, id, tag, desc);
        this.slope = slope;
        this.yint = yint;
        this.units = units;
        this.color = color;

        /* set defaults */
        this.num = 0;
        this.devref = "dev0";
        this.tag = "CH0";
        this.desc = "Input Channel";

        /* create list for raw data */
        raw_value_list = new Gee.LinkedList<double?> ();
        raw_value_list_size = 0;

        /* create calibration object */
        cal = new Calibration ();
    }

    public AIChannel.from_xml_node (Xml.Node *node) {
        string val;

        if (node->type == Xml.ElementType.ELEMENT_NODE &&
            node->type != Xml.ElementType.COMMENT_NODE) {
            id = node->get_prop ("id");
            devref = node->get_prop ("ref");
            /* iterate through node children */
            for (Xml.Node *iter = node->children;
                 iter != null;
                 iter = iter->next) {
                if (iter->name == "property") {
                    switch (iter->get_prop ("name")) {
                        case "tag":
                            tag = iter->get_content ();
                            break;
                        case "desc":
                            desc = iter->get_content ();
                            break;
                        case "num":
                            val = iter->get_content ();
                            num = int.parse (val);
                            break;
                        case "calref":
                            /* this should maybe be an object property,
                             * fix later maybe */
                            calref = iter->get_content ();
                            break;
                        default:
                            break;
                    }
                }
            }
        }
    }

    public void add_raw_value (double value) {
        double conv = value;
        /* clip the input */
        conv = (conv <  0.0) ?  0.0 : conv;
        conv = (conv > 10.0) ? 10.0 : conv;
        conv = (conv / 10.0) * 65535.0;  /* assume 0-10V range */

//        raw_value_list.insert (0, conv);
        raw_value_list.add (conv);
        if (raw_value_list.size > raw_value_list_size) {
//            conv = raw_value_list.poll_tail ();
            conv = raw_value_list.poll_head ();
        }
    }

    public void update_avg_value () {
        double sum = 0.0;

        if (raw_value_list.size > 0) {
            foreach (double value in raw_value_list) {
                /* !!! for now assume 16 bit with 0-10V range - fix later */
//                value = ((value / 65535.0) * 10.0) * slope + yint;
                value = (value / 65535.0) * 10.0;
                sum += value;
            }

            avg_value = sum / raw_value_list.size;
        }
    }

    public override string to_string () {
        return base.to_string ();
    }
}
