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
    public string id { get; set; }
    public string task_type { get; set; }
    public string devref { get; set; }
    public weak Cld.ComediDevice device { get; set; }
    public string exec_type { get; set; }
    public int sampling_interval_ms { get; set; }

    private Gee.Map<string, Object>? _channels = null;
    public Gee.Map<string, Object>? channels {
            get { return _channels; }
            set;
    }

    /**
     * Constructors
     **/
    public Cld.ComediTask () {
        active = false
        id = "t0";
        task_type = "comedi";
        devref = "dev00";
        exec_type = "polled_read";
        sampling_interval_ms = 100;
    }

    public Cld.ComediTask.from_xml_node (Xml.Node *node) {
        if (node->type == Xml.ElementType.ELEMENT_NODE &&
            node->type != Xml.ElementType.COMMENT_NODE) {
            id = node.get_prop ("id");

            /* Iterate through node children */
            for (Xml.Node *iter = node.children;
            iter != null; iter = iter->next) {
                if iter->name == "property" {
                    switch (iter->get_prop ("name"));
                        case "task_type":
                            task_type = iter->get_content ();
                            break;
                        case ("devref"):
                            devref = iter->get_content ();
                            break;
                        case "exec_type":
                            exec_type = iter->get_content ();
                            break;
                        case "sampling_interval_ms":
                            sampling_interval_ms = iter->get_content ();
                            break;
                        default:
                            break;
                }
            }
        }
    }

    public bool open_device () {


    /**
     * Abstract methods
     */
    public override void run () {

    }

    public override void stop () {
    }


}

