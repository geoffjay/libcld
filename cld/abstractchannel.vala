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
 * Skeletal implementation of the {@link Channel} interface.
 *
 * Contains common code shared by all channel implementations.
 */
public abstract class Cld.AbstractChannel : AbstractObject, Channel {

    /**
     * {@inheritDoc}
     */
    public abstract int num { get; set; }

    /**
     * {@inheritDoc}
     */
    public abstract string devref { get; set; }

    /**
     * {@inheritDoc}
     */
    public abstract string tag { get; set; }

    /**
     * {@inheritDoc}
     */
    public abstract string desc { get; set; }

    public override string to_string () {
        string str_data  = "CldChannel\n";
               str_data += " [id  ] : %s\n".printf (id);
               str_data += " [num ] : %d\n".printf (num);
               str_data += " [dev ] : %s\n".printf (devref);
               str_data += " [tag ] : %s\n".printf (tag);
               str_data += " [desc] : %s\n".printf (desc);
        return str_data;
    }

//    public Channel (int    num,
//                    string id,
//                    string tag,
//                    string desc) {
//        /* instantiate new object */
//        GLib.Object (num:    num,
//                     id:     id,
//                     tag:    tag,
//                     desc:   desc);
//    }

//    public Channel.with_devref (int    num,
//                                string id,
//                                string devref,
//                                string tag,
//                                string desc) {
//        /* instantiate new object */
//        GLib.Object (num:    num,
//                     id:     id,
//                     devref: devref,
//                     tag:    tag,
//                     desc:   desc);
//    }

//    public Channel.from_xml_node (Xml.Node *node) {
//        string ctype = "";
//        string direction = "";

//        if (node->type == Xml.ElementType.ELEMENT_NODE &&
//            node->type != Xml.ElementType.COMMENT_NODE) {
//            type = node->get_prop ("type");
//            direction = node->get_prop ("direction");
//            switch (type) {
//                case "analog":
//                    if (direction == "input") {
//                        return new AIChannel.from_xml_node (node);
//                    } else if (direction == "output") {
//                        return new AOChannel.from_xml_node (node);
//                    }
//                    break;
//                case "digital":
//                    if (direction == "input") {
//                        return new DIChannel.from_xml_node (node);
//                    } else if (direction == "output") {
//                        return new DOChannel.from_xml_node (node);
//                    }
//                    break;
//                case "calculation":
//                    /* for now virtual channels are only of one type */
//                    return new VChannel.from_xml_node (node);
//                    break;
//                default:
//                    break;
//            }
//    }
}
