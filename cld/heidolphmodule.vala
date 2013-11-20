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
 * Authors:
 *  Geoff Johnson <geoff.jay@gmail.com>
 *  Steve Roy <sroy1966@gmail.com>
 */

/**
 * This is very much intended to service an immediate specific need and will not
 * be suitable for a generic scenario.
 */
public class Cld.HeidolphModule : AbstractModule {

    /**
     * Property backing fields.
     */
    private Gee.Map<string, Object> _objects;

    int timeout_ms = 100;
    uint source_id;

    /**
     * {@inheritDoc}
     */
    public override string id { get; set; }

    /**
     * {@inheritDoc}
     */
    public override bool loaded { get; set; default = false; }

    /**
     * {@inheritdoc}
     */
    public override string devref { get; set; }

    /**
     * {@inheritDoc}
     */
    public override string portref { get; set; }

    /**
     * {@inheritDoc}
     */
    public override weak Port port { get; set; }

    /**
     * {@inheritDoc}
     */
    public override Gee.Map<string, Object> objects {
        get { return (_objects); }
        set { update_objects (value); }
    }

    public bool running { get; set; default = false; }

    public weak Gee.Map<string, Object> channels { get; set; }

    /**
     * Default construction.
     */
    public HeidolphModule () {
    }

    /**
     * Full construction using available settings.
     */
    public HeidolphModule.full (string id, Port port) {
       this.id = id;
       this.port = port;
    }

    /**
     * Alternate construction method that uses an XML node to populate the settings.
     */
    public HeidolphModule.from_xml_node (Xml.Node *node) {
        if (node->type == Xml.ElementType.ELEMENT_NODE &&
            node->type != Xml.ElementType.COMMENT_NODE) {
            id = node->get_prop ("id");
            /* iterate through node children */
            for (Xml.Node *iter = node->children;
                 iter != null;
                 iter = iter->next) {
                if (iter->name == "property") {
                    switch (iter->get_prop ("name")) {
                        case "port":
                            portref = iter->get_content ();
                            break;
                        default:
                            break;
                    }
                }
            }
        }
    }

    /**
     * Start the mixer
     */
     public bool run () {
        Cld.debug ("Heidolph: run ()\n");

        return true;
     }

    /**
     * Stop the mixer
     */
    public bool stop () {
        Cld.debug ("Heidolph: stop ())\n");

        return true;
    }

    /**
     * Callback event that fetches new data from the serial port.
     */
    private bool new_data_cb () {
        Cld.debug ("Heidolph: new_data_cb ()\n");

        return true;
    }


    /**
     * Set the mixer speed [RPM]
     */
    public bool set_speed (double speed_set) {
        Cld.debug ("Heidolph: set_speed ()\n");

        return true;
    }

    /**
     * {@inheritDoc}
     */
    public override bool load () {
        loaded = true;
        if (!port.open ()) {
            Cld.debug ("Could not open port, id: %s\n", id);
            loaded = false;
        } else {
            stop ();
            source_id = Timeout.add (timeout_ms, new_data_cb);
            Cld.debug ("HeidolphModule loaded");
        }
        return loaded;
    }

    /**
     * {@inheritDoc}
     */
    public override void unload () {
        if (running)
            stop ();
        if (loaded) {
            port.close ();
        loaded = false;
        }
        Cld.debug ("HeidolphModule unloaded");
    }

    /**
     * {@inheritDoc}
     */
    public override void update_objects (Gee.Map<string, Object> val) {
        _objects = val;
    }
}


