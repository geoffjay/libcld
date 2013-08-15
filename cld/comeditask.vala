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

using Comedi;

/**
 * An task object that uses a Comedi device.
 */

public class Cld.ComediTask : AbstractTask {

   /**
    * Abstract properties
    */
    public override bool active { get; set; }
    public override string id { get; set; }
    public string devref { get; set; }
    public Device device { get; set; }
    public string exec_type { get; set; }
    public int subdevice { get; set; }
    public string poll_type { get; set; }
    public int poll_interval_ms { get; set; }

    private Gee.Map<string, Object>? _channels = null;
    public Gee.Map<string, Object>? channels {
            get { return _channels; }
            set { _channels = value; }
    }

    /**
     * Constructors
     **/
    public ComediTask () {
        active = false;
        id = "tk0";
        devref = "dev00";
        device = new ComediDevice ();
        exec_type = "polling";
        subdevice = 0;
        poll_type = "read";
        poll_interval_ms = 100;
    }

    public ComediTask.from_xml_node (Xml.Node *node) {
        if (node->type == Xml.ElementType.ELEMENT_NODE &&
            node->type != Xml.ElementType.COMMENT_NODE) {
            id = node->get_prop ("id");

            /* Iterate through node children */
            for (Xml.Node *iter = node->children;
            iter != null; iter = iter->next) {
                if (iter->name == "property") {
                    switch (iter->get_prop ("name")) {
                        case "devref":
                            devref = iter->get_content ();
                            break;
                        case "exec-type":
                            exec_type = iter->get_content ();
                            break;
                        case "subdevice":
                            subdevice = int.parse (iter->get_content ());
                            break;
                        case "poll-type":
                            poll_type = iter->get_content ();
                            break;
                        case "poll-interval-ms":
                            poll_interval_ms = int.parse (iter->get_content ());
                            break;
                        default:
                            break;
                    }
                }
            }
        }
    }

    public override string to_string () {
        string str_data  = "Cld.ComediTask\n";
               str_data += " [id  ] : %s\n".printf (id);
               str_data += " [devref] : %s\n".printf (devref);
               str_data += " [exec_type] : %s\n".printf (exec_type);
               str_data += " [subdevice] : %d\n".printf (subdevice);
               str_data += " [poll_type] : %s\n".printf (poll_type);
               str_data += " [poll_interval_ms] : %d\n".printf (poll_interval_ms);
        return str_data;
    }


    /**
     * Abstract methods
     */
    public override void run () {
        var device = this.device;
        (device as ComediDevice).open ();
        var information = (device as ComediDevice).info ();
        message ((information as ComediDevice.Information).to_string ());
    }

    public override void stop () {
        this.device.close ();
    }


}

