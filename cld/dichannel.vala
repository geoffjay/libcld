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
 * Digital input channel used in control and logging.
 */
public class Cld.DIChannel : Cld.AbstractChannel, Cld.DChannel, Cld.IChannel {

    /**
     * Property backing fields.
     */
    private bool _state;

    /**
     * {@inheritDoc}
     */
    public virtual bool state {
        get { return _state; }
        set {
            _state = value;
            new_value (id, value);
        }
    }

    /* default constructor */
    public DIChannel () {
        /* set defaults */
        this.num = 0;
        this.devref = "dev0";
        this.tag = "CH0";
        this.desc = "Output Channel";
        state = false;
    }

    public DIChannel.from_xml_node (Xml.Node *node) {
        string value;

        this.node = node;
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
                        case "subdevnum":
                            value = iter->get_content ();
                            subdevnum = int.parse (value);
                            break;
                        default:
                            break;
                    }
                }
            }
        }
        connect_signals ();
    }

    /**
     * Connect all the notify signals that should require the node to update
     */
    private void connect_signals () {
        notify["tag"].connect ((s, p) => {
            Cld.debug ("Property %s changed for %s", p.get_name (), uri);
            update_node ();
        });

        notify["desc"].connect ((s, p) => {
            Cld.debug ("Property %s changed for %s", p.get_name (), uri);
            update_node ();
        });

        notify["num"].connect ((s, p) => {
            Cld.debug ("Property %s changed for %s", p.get_name (), uri);
            update_node ();
        });

        notify["subdevnum"].connect ((s, p) => {
            Cld.debug ("Property %s changed to %d for %s", p.get_name (), subdevnum,  uri);
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
                        case "tag":
                            iter->set_content (tag);
                            break;
                        case "desc":
                            iter->set_content (desc);
                            break;
                        case "num":
                            iter->set_content (num.to_string ());
                            break;
                        case "subdevnum":
                            iter->set_content (subdevnum.to_string ());
                            Cld.debug ("Writing %s to XML node for subdevnum", subdevnum.to_string ());
                            break;
                        default:
                            break;
                    }
                }
            }
        }
    }
}
