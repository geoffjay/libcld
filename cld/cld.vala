/*
** Copyright (C) 2010 Geoff Johnson <geoff.jay@gmail.com>
**
** This program is free software; you can redistribute it and/or modify
** it under the terms of the GNU General Public License as published by
** the Free Software Foundation; either version 2 of the License, or
** (at your option) any later version.
**
** This program is distributed in the hope that it will be useful,
** but WITHOUT ANY WARRANTY; without even the implied warranty of
** MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
** GNU General Public License for more details.
**
** You should have received a copy of the GNU General Public License
** along with this program; if not, write to the Free Software
** Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
*/

using GLib;
using Gee;

namespace Cld {

    /***
     * These methods are responsible for loading xml configuration data into
     * objects that will be placed inside of another collection.
     */

    /***
     * xml_node_to_analog_input_channel
     *
     * @param:
     * @return:
     */
    public Cld.AnalogInputChannel xml_node_to_analog_input_channel (Xml.Node *node) {
        string id = "";
        string devref = "";
        string tag = "";
        string desc = "";
        int num = 0;
        double slope = 0.0;
        double yint = 0.0;
        string units = "";
        string color = "";
        string value = "";

        if (node->type == Xml.ElementType.ELEMENT_NODE) {
            id = node->get_prop ("id");
            devref = node->get_prop ("devref");
        }

        for (Xml.Node *child = node->children; child != null; child = child->next) {
            if (child->type != Xml.ElementType.ELEMENT_NODE) {
                continue;
            }

            if (child->name == "tag") {
                tag = child->get_content ();
            } else if (child->name == "desc") {
                desc = child->get_content ();
            } else if (child->name == "num") {
                value = child->get_content ();
                num = value.to_int ();
            } else if (child->name == "slope") {
                value = child->get_content ();
                slope = value.to_double ();
            } else if (child->name == "yint") {
                value = child->get_content ();
                yint = value.to_double ();
            } else if (child->name == "units") {
                units = child->get_content ();
            } else if (child->name == "color") {
                color = child->get_content ();
            }
        }

        return new Cld.AnalogInputChannel (id, tag, desc, num, slope, yint, units, color);
    }

    /***
     * xml_node_to_analog_output_channel
     *
     * @param:
     * @return:
     */
    public Cld.AnalogOutputChannel xml_node_to_analog_output_channel (Xml.Node *node) {
        string id = "";
        string tag = "";
        string desc = "";
        int num = 0;
        string value = "";

        if (node->type == Xml.ElementType.ELEMENT_NODE)
            id = node->get_prop ("id");

        for (Xml.Node *child = node->children; child != null; child = child->next) {
            if (child->type != Xml.ElementType.ELEMENT_NODE) {
                continue;
            }

            if (child->name == "tag") {
                tag = child->get_content ();
            } else if (child->name == "desc") {
                desc = child->get_content ();
            } else if (child->name == "num") {
                value = child->get_content ();
                num = value.to_int ();
            }
        }

        /* constructor for ao channel expects existence which hasn't been implemented yet, just dummy for now */
        return new Cld.AnalogOutputChannel (num, id, tag, desc, 0);
    }

    /***
     * xml_node_to_daq
     *
     * @param:
     * @return:
     */
    public Cld.Daq xml_node_to_daq (Xml.Node *node) {
        string value = "";
        double rate = 0.0;

        for (Xml.Node *child = node->children; child != null; child = child->next) {
            if (child->type != Xml.ElementType.ELEMENT_NODE) {
                continue;
            }

            if (child->name == "rate") {
                value = child->get_content ();
                rate = value.to_double ();
            }
        }

        return new Cld.Daq (rate);
    }

    /***
     * xml_node_to_device
     *
     * @param:
     * @return:
     */
    public Cld.Device xml_node_to_device (Xml.Node *node) {
        string id = "";
//        int    hw_type;
//        int    driver_type;
        string name = "";
        string file = "";

//        string value;

        if (node->type == Xml.ElementType.ELEMENT_NODE)
            id = node->get_prop ("id");

        /* currently this doesn't take into account the actual options that
         * can be set, fix later */
//        value = node->get_prop ("type");
//        hw_type = value.to_int ();
//        value = node->get_prop ("driver");
//        driver_type = value.to_int ();

        for (Xml.Node *child = node->children; child != null; child = child->next) {
            if (child->type != Xml.ElementType.ELEMENT_NODE) {
                continue;
            }

            if (child->name == "name")
                name = child->get_content ();
            else if (child->name == "file")
                file = child->get_content ();
        }

        return new Cld.Device (id, 0/*hw_type*/, 0/*driver_type*/, name, file);
    }

    /***
     * xml_node_to_log
     *
     * @param:
     * @return:
     */
    public Cld.Log xml_node_to_log (Xml.Node *node) {
        string id = "";
        string name = "";
        string path = "";
        string file = "";
        string value = "";
        double rate = 0.0;

        if (node->type == Xml.ElementType.ELEMENT_NODE)
            id = node->get_prop ("id");

        for (Xml.Node *child = node->children; child != null; child = child->next) {
            if (child->type != Xml.ElementType.ELEMENT_NODE) {
                continue;
            }

            if (child->name == "name")
                name = child->get_content ();
            else if (child->name == "path")
                path = child->get_content ();
            else if (child->name == "file")
                file = child->get_content ();
            else if (child->name == "rate")
            {
                value = child->get_content ();
                rate = value.to_double ();
            }
        }

        return new Cld.Log (id, name, path, file, rate);
    }

    /***
     * xml_node_to_pid
     *
     * @param:
     * @return:
     */
    public Cld.Pid xml_node_to_pid (Xml.Node *node) {
        string id = "";
        string value = "";
        double sp = 0.0;
        double kp = 0.0;
        double ki = 0.0;
        double kd = 0.0;

        if (node->type == Xml.ElementType.ELEMENT_NODE)
            id = node->get_prop ("id");

        for (Xml.Node *child = node->children; child != null; child = child->next) {
            if (child->type != Xml.ElementType.ELEMENT_NODE) {
                continue;
            }

            if (child->name == "sp") {
                value = child->get_content ();
                sp = value.to_double ();
            } else if (child->name == "kp") {
                value = child->get_content ();
                kp = value.to_double ();
            } else if (child->name == "ki") {
                value = child->get_content ();
                ki = value.to_double ();
            } else if (child->name == "kd") {
                value = child->get_content ();
                kd = value.to_double ();
            }
        }

        return new Cld.Pid (id, sp, kp, ki, kd);
    }

    /***
     * These methods are responsible for building the collections of objects
     * using the xml_node_to_* methods from above.
     */

    /***
     * build_analog_input_channel_list
     *
     * @param:
     * @return:
     */
    public Gee.Map<string, Cld.AnalogInputChannel> build_analog_input_channel_list (Cld.XmlConfig cfg) {
        /* request the nodeset from the configuration */
        Xml.XPath.NodeSet *nodes = cfg.nodes_from_xpath ("//app/channels/analog/input/channel");
        Xml.Node *node = nodes->item (0);
        Gee.Map<string, Cld.AnalogInputChannel> channels = new Gee.HashMap<string, Cld.AnalogInputChannel> ();

        for (Xml.Node *iter = node; iter != null; iter = iter->next) {
            if (iter->type == Xml.ElementType.ELEMENT_NODE) {
                /* for some reason this isn't being restricted to the element requested
                 * by the xpath query so this additional check is required */
                if (iter->name == "channel") {
                    Cld.AnalogInputChannel ch = Cld.xml_node_to_analog_input_channel (iter);
                    channels.set (ch.id, ch);
                }
            }
        }

        return channels;
    }

    /***
     * build_analog_output_channel_list
     *
     * @param:
     * @return:
     */
    public Gee.Map<string, Cld.AnalogOutputChannel> build_analog_output_channel_list (Cld.XmlConfig cfg) {
        /* request the nodeset from the configuration */
        Xml.XPath.NodeSet *nodes = cfg.nodes_from_xpath ("//app/channels/analog/output/channel");
        Xml.Node *node = nodes->item (0);
        Gee.Map<string, Cld.AnalogOutputChannel> channels = new Gee.HashMap<string, Cld.AnalogOutputChannel> ();

        for (Xml.Node *iter = node; iter != null; iter = iter->next) {
            if (iter->type == Xml.ElementType.ELEMENT_NODE) {
                /* for some reason this isn't being restricted to the element requested
                 * by the xpath query so this additional check is required */
                if (iter->name == "channel") {
                    Cld.AnalogOutputChannel ch = Cld.xml_node_to_analog_output_channel (iter);
                    channels.set (ch.id, ch);
                }
            }
        }

        return channels;
    }

    /***
     * build_daq
     *
     * @param:
     * @return:
     */
    public Cld.Daq build_daq (Cld.XmlConfig cfg) {
        /* request the nodeset from the configuration */
        Xml.XPath.NodeSet *nodes = cfg.nodes_from_xpath ("//app/daq");
        Xml.Node *node = nodes->item (0);
        Cld.Daq daq = null;

        for (Xml.Node *iter = node; iter != null; iter = iter->next) {
            if (iter->type == Xml.ElementType.ELEMENT_NODE) {
                /* for some reason this isn't being restricted to the element requested
                 * by the xpath query so this additional check is required */
                if (iter->name == "daq") {
                    daq = Cld.xml_node_to_daq (iter);
                    Gee.Map<string, Cld.Device> devs = Cld.build_device_list (cfg);
                    daq.update_devices (devs);
                }
            }
        }

        return daq;
    }

    /***
     * build_device_list
     *
     * @param:
     * @return:
     */
    public Gee.Map<string, Cld.Device> build_device_list (Cld.XmlConfig cfg) {
        /* request the nodeset from the configuration */
        Xml.XPath.NodeSet *nodes = cfg.nodes_from_xpath ("//app/daq/device");
        Xml.Node *node = nodes->item (0);
        Gee.Map<string, Cld.Device> devs = new Gee.HashMap<string, Cld.Device> ();

        for (Xml.Node *iter = node; iter != null; iter = iter->next) {
            if (iter->type == Xml.ElementType.ELEMENT_NODE) {
                /* for some reason this isn't being restricted to the element requested
                 * by the xpath query so this additional check is required */
                if (iter->name == "device") {
                    Cld.Device dev = Cld.xml_node_to_device (iter);
                    devs.set (dev.id, dev);
                }
            }
        }

        return devs;
    }

    /***
     * build_log_list
     *
     * @param:
     * @return:
     */
    public Gee.Map<string, Cld.Log> build_log_list (Cld.XmlConfig cfg) {
        /* request the nodeset from the configuration */
        Xml.XPath.NodeSet *nodes = cfg.nodes_from_xpath ("//app/logs/log");
        Xml.Node *node = nodes->item (0);
        Gee.Map<string, Cld.Log> logs = new Gee.HashMap<string, Cld.Log> ();

        for (Xml.Node *iter = node; iter != null; iter = iter->next) {
            if (iter->type == Xml.ElementType.ELEMENT_NODE) {
                /* for some reason this isn't being restricted to the element requested
                 * by the xpath query so this additional check is required */
                if (iter->name == "log") {
                    Cld.Log log = Cld.xml_node_to_log (iter);
                    logs.set (log.id, log);
                }
            }
        }

        return logs;
    }

    /***
     * build_pid_list
     *
     * @param:
     * @return:
     */
    public Gee.Map<string, Cld.Pid> build_pid_list (Cld.XmlConfig cfg) {
        /* request the nodeset from the configuration */
        Xml.XPath.NodeSet *nodes = cfg.nodes_from_xpath ("//app/control/pid");
        Xml.Node *node = nodes->item (0);
        Gee.Map<string, Cld.Pid> pids = new Gee.HashMap<string, Cld.Pid> ();

        for (Xml.Node *iter = node; iter != null; iter = iter->next) {
            if (iter->type == Xml.ElementType.ELEMENT_NODE) {
                /* for some reason this isn't being restricted to the element requested
                 * by the xpath query so this additional check is required */
                if (iter->name == "pid") {
                    Cld.Pid pid = Cld.xml_node_to_pid (iter);
                    pids.set (pid.id, pid);
                }
            }
        }

        return pids;
    }
}
