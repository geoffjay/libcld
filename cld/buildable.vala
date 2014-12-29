/**
 * libcld
 * Copyright (c) 2015, Geoff Johnson, All rights reserved.
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 3.0 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library.
 */

/**
 * A common interface for buildable objects.
 *
 * NOTE: Should this be internal? Might limit extensibility if it were.
 */
public interface Cld.Buildable : GLib.Object {

    protected abstract string xml { get; }

    protected abstract string xsd { get; }

    public static unowned string get_xml_default () {
        return "<object type=\"buildable\"/>";
    }

    public static unowned string get_xsd_default () {
        return """
                <xs:element name="object">
                  <xs:attribute name="id" type="xs:string" use="required"/>
                  <xs:attribute name="type" type="xs:string" use="required"/>
                </xs:element>
               """;
    }

    /**
     * Build the object using an XML node
     *
     * @param node XML node to construction the object from
     */
    protected abstract void build_from_node (Xml.Node *node) throws GLib.Error;
}
