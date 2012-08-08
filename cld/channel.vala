/**
 * Copyright (C) 2010 Geoff Johnson <geoff.jay@gmail.com>
 *
 * This file is part of libcld.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
 */

namespace Cld {
    public abstract class Channel : Cld.Object {
        /* inherited properties */
        public override string id     { get; set; }

        /* inheritable properties */
        public abstract int num       { get; set; }
        public abstract string devref { get; set; }
        public abstract string tag    { get; set; }
        public abstract string desc   { get; set; }

        /* default constructor */
        public Channel () {
            id = "ch0";
            num = 0;
            devref = "dev0";
            tag = "CH0";
            desc = "Channel";
        }

        public override string to_string () {
            string str_data  = "CldChannel\n";
                   str_data += "──┬───────\n";
                   str_data += "  ├ [id  ] : %s\n".printf (id);
                   str_data += "  ├ [num ] : %d\n".printf (num);
                   str_data += "  ├ [dev ] : %s\n".printf (devref);
                   str_data += "  ├ [tag ] : %s\n".printf (tag);
                   str_data += "  ├ [desc] : %s\n".printf (desc);
            return str_data;
        }

//        public Channel (int    num,
//                        string id,
//                        string tag,
//                        string desc) {
//            /* instantiate new object */
//            GLib.Object (num:    num,
//                         id:     id,
//                         tag:    tag,
//                         desc:   desc);
//        }

//        public Channel.with_devref (int    num,
//                                    string id,
//                                    string devref,
//                                    string tag,
//                                    string desc) {
//            /* instantiate new object */
//            GLib.Object (num:    num,
//                         id:     id,
//                         devref: devref,
//                         tag:    tag,
//                         desc:   desc);
//        }

//        public Channel.from_xml_node (Xml.Node *node) {
//            string ctype = "";
//            string direction = "";

//            if (node->type == Xml.ElementType.ELEMENT_NODE &&
//                node->type != Xml.ElementType.COMMENT_NODE) {
//                type = node->get_prop ("type");
//                direction = node->get_prop ("direction");
//                switch (type) {
//                    case "analog":
//                        if (direction == "input") {
//                            return new AIChannel.from_xml_node (node);
//                        } else if (direction == "output") {
//                            return new AOChannel.from_xml_node (node);
//                        }
//                        break;
//                    case "digital":
//                        if (direction == "input") {
//                            return new DIChannel.from_xml_node (node);
//                        } else if (direction == "output") {
//                            return new DOChannel.from_xml_node (node);
//                        }
//                        break;
//                    case "calculation":
//                        /* for now virtual channels are only of one type */
//                        return new VChannel.from_xml_node (node);
//                        break;
//                    default:
//                        break;
//                }
//        }
    }

    /**
     * AChannel:
     *
     * Analog channel interface class.
     */
    public interface AChannel : Channel {
        public abstract Calibration cal     { get; set; }
        public abstract double value        { get; set; }
        public abstract double scaled_value { get; set; }
        public abstract double avg_value    { get; set; }
    }

    /**
     * DChannel:
     *
     * Digital channel interface class.
     */
    public interface DChannel : Channel {
    }

    /**
     * IChannel:
     *
     * Input channel interface class, I is for input not interface.
     */
    public interface IChannel : Channel {
    }

    /**
     * OChannel:
     *
     * Output channel interface class.
     */
    public interface OChannel : Channel {
    }

    /* REVIEW:
     * inheriting Channel interface might be redundant when the object is
     * also already inheriting other interfaces that inherit it as well */

    /**
     * AIChannel:
     *
     * Analog input channel class.
     */
    public class AIChannel : Channel, AChannel, IChannel {
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
//            base (num, id, tag, desc);
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

//            raw_value_list.insert (0, conv);
            raw_value_list.add (conv);
            if (raw_value_list.size > raw_value_list_size) {
//                conv = raw_value_list.poll_tail ();
                conv = raw_value_list.poll_head ();
            }
        }

        public void update_avg_value () {
            double sum = 0.0;

            if (raw_value_list.size > 0) {
                foreach (double value in raw_value_list) {
                    /* !!! for now assume 16 bit with 0-10V range - fix later */
//                    value = ((value / 65535.0) * 10.0) * slope + yint;
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

    /**
     * AOChannel:
     *
     * Analog output channel class.
     */
    public class AOChannel : Channel, AChannel, OChannel {
        /* properties - from Object */
        public override string id           { get; set; }
        /* properties - from Channel */
        public override int num             { get; set; }
        public override string devref       { get; set; }
        public override string tag          { get; set; }
        public override string desc         { get; set; }
        /* properties - from AChannel */
        public Calibration cal              { get; set; }
        public double value                 { get; set; }
        public double scaled_value          { get; set; }
        public double avg_value             { get; set; }
        /* properties */
        public bool manual                  { get; set; }

        /* default constructor */
        public AOChannel (int    num,
                          string id,
                          string tag,
                          string desc) {
            /* pass on to base class constructor */
//            base (num, id, tag, desc);
            GLib.Object (num:  num,
                         id:   id,
                         tag:  tag,
                         desc: desc);
            value = 0.0;
        }

        public AOChannel.from_xml_node (Xml.Node *node) {
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
                            default:
                                break;
                        }
                    }
                }
            }
        }

        public override string to_string () {
            return base.to_string ();
        }
    }

    /**
     * DIChannel:
     *
     * Digital input channel class.
     */
    public class DIChannel : Channel, DChannel, IChannel {
        /* properties - from Object */
        public override string id { get; set; }
        /* properties - from Channel */
        public override int num             { get; set; }
        public override string devref       { get; set; }
        public override string tag          { get; set; }
        public override string desc         { get; set; }
        /* properties */
        public bool state { get; set; }

        /* default constructor */
        public DIChannel (int    num,
                          string id,
                          string tag,
                          string desc) {
            /* pass on to base class constructor */
//            base (num, id, tag, desc);
            GLib.Object (num:  num,
                         id:   id,
                         tag:  tag,
                         desc: desc);
            state = false;
        }

        public DIChannel.from_xml_node (Xml.Node *node) {
            string value;

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
                                value = iter->get_content ();
                                num = int.parse (value);
                                break;
                            default:
                                break;
                        }
                    }
                }
            }
        }

        public override string to_string () {
            return base.to_string ();
        }
    }

    /**
     * DOChannel:
     *
     * Digital output channel class.
     */
    public class DOChannel : Channel, DChannel, OChannel {
        /* properties - from Object */
        public override string id       { get; set; }
        /* properties - from Channel */
        public override int num         { get; set; }
        public override string devref   { get; set; }
        public override string tag      { get; set; }
        public override string desc     { get; set; }
        /* properties */
        public bool state               { get; set; }

        /* default constructor */
        public DOChannel (int    num,
                          string id,
                          string tag,
                          string desc) {
            /* pass on to base class constructor */
//            base (num, id, tag, desc);
            GLib.Object (num:  num,
                         id:   id,
                         tag:  tag,
                         desc: desc);
            state = false;
        }

        public DOChannel.from_xml_node (Xml.Node *node) {
            string value;

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
                                value = iter->get_content ();
                                num = int.parse (value);
                                break;
                            default:
                                break;
                        }
                    }
                }
            }
        }

        public override string to_string () {
            return base.to_string ();
        }
    }

    /**
     * VChannel:
     *
     * Virtual channel that can be used to execute expressions.
     */
    public class VChannel : Channel {
        /* properties */
        public override string id       { get; set; }
        /* properties - from Channel */
        public override int num         { get; set; }
        public override string devref   { get; set; }
        public override string tag      { get; set; }
        public override string desc     { get; set; }

        public string expression        { get; set; }

        /* default constructor */
        public VChannel (int    num,
                         string id,
                         string tag,
                         string desc) {
            /* pass on to base class constructor */
//            base (num, id, tag, desc);
            GLib.Object (num:  num,
                         id:   id,
                         tag:  tag,
                         desc: desc);
        }

        public VChannel.from_xml_node (Xml.Node *node) {
            string value;

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
                            case "expression":
                                expression = iter->get_content ();
                                break;
                            case "num":
                                value = iter->get_content ();
                                num = int.parse (value);
                                break;
                            default:
                                break;
                        }
                    }
                }
            }
        }

        public override string to_string () {
            return base.to_string ();
        }
    }
}
