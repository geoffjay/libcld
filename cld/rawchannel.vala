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

public class Cld.RawChannel : Cld.AbstractChannel, Cld.Buildable {

    /* Property backing fields */

    private string _xml = """
      <cld:object id="raw0" type="channel" ch-type="raw" ref="cld://daqctl0/dev0">
        <cld:property name="tag">RAW0</cld:property>
        <cld:property name="desc">Raw Channel</cld:property>
        <cld:property name="num">0</cld:property>
      </cld:object>
    """;

    private string _xsd = """
      <xs:element name="object">
        <xs:attribute name="id" type="xs:string" use="required"/>
        <xs:attribute name="type" type="xs:string" use="required"/>
        <xs:attribute name="ch-type" type="xs:string" use="required"/>
        <xs:attribute name="ref" type="xs:string" use="required"/>
        <!-- FIXME: This is missing the simple type properties. -->
      </xs:element>
    """;

    /* Properties */

    /**
     * 16 bit value mean to be read from DAC devices.
     *
     * FIXME: Would make more sense to use a Variant and allow for 8/16/32 bit
     */
    public uint16 value { get; set; }

    /**
     * {@inheritDoc}
     */
    protected virtual string xml {
        get { return _xml; }
    }

    /**
     * {@inheritDoc}
     */
    protected virtual string xsd {
        get { return _xsd; }
    }

    /**
     * Default construction.
     */
    public RawChannel () {
        set_num (0);
        //this.devref = "/daqctl0/dev0";
        this.tag = "RAW0";
        this.desc = "Raw Channel";

        connect_signals ();
    }

    /**
     * Construction using
     */
    public RawChannel.from_xml_node (Xml.Node *node) {
        this.node = node;

        try {
            build_from_node (node);
        } catch (GLib.Error e) {
            critical (e.message);
        }
        connect_signals ();
    }

    /**
     * {@inheritDoc}
     */
    protected virtual void build_from_node (Xml.Node *node) throws GLib.Error {
        /* Assuming that node type is valid */
        if (node->children == null)
            throw new Cld.ConfigurationError.EMPTY_NODESET (
                    "Configuration nodeset received is empty"
                );

        /* Read in the attributes */
        id = node->get_prop ("id");
        //devref = node->get_prop ("ref");

        /* Read in the property/class element nodes */
        for (Xml.Node *iter = node->children; iter != null; iter = iter->next) {
            if (iter->name == "property") {
                switch (iter->get_prop ("name")) {
                    case "tag":
                        tag = iter->get_content ();
                        break;
                    case "desc":
                        desc = iter->get_content ();
                        break;
                    case "num":
                        var val = iter->get_content ();
                        set_num (int.parse (val));
                        break;
                    case "alias":
                        alias = iter->get_content ();
                        break;
                    default:
                        break;
                }
            }
        }
    }

    /**
     * Connect all the notify signals that are used to keep the backend XML
     * current.
     */
    private void connect_signals () {
        notify["tag"].connect ((s, p) => {
            message ("Property %s changed for %s", p.get_name (), uri);
            update_node ();
        });

        notify["desc"].connect ((s, p) => {
            message ("Property %s changed for %s", p.get_name (), uri);
            update_node ();
        });

        notify["num"].connect ((s, p) => {
            message ("Property %s changed for %s", p.get_name (), uri);
            update_node ();
        });

        notify["alias"].connect ((s, p) => {
            message ("Property %s changed for %s", p.get_name (), uri);
            update_node ();
        });
    }

    /**
     * Update the node data from this object.
     *
     * FIXME: This should be enforced through an interface, eg. Cld.Configurable.
     */
    private void update_node () {
        for (Xml.Node *iter = node->children; iter != null; iter = iter->next) {
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
                    case "alias":
                        iter->set_content (alias);
                        break;
                    default:
                        break;
                }
            }
        }
    }
}
