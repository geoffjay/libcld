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
 * Class use to use as an interface to the library.
 *
 * XXX some of this may not make sense functioning as a buildable object but
 * until more separation is made between those and other library objects
 * the id and to_string will stay and just be ignored.
 *
 * This contains the map of Cld.Objects and handles high level executive
 * tasks or delegates them to the various functional controllers that it contains.
 */
public class Cld.Context : Cld.AbstractContainer {

    /**
     * Default construction.
     */
    public Context () { }

    /**
     * Construction using a configuration file.
     */
    public Context.from_config (Cld.XmlConfig xml) {
        var builder = new Cld.Builder.from_xml_config (xml);
        objects = builder.get_objects ();

        debug (to_string_recursive ());

        generate_ref_list ();

        setup_references ();
        setup_controllers ();
    }

    /**
     * Generate references between objects.
     */
    private void setup_references () {
        debug ("Generating references...");
        var list = get_descendant_ref_list ();
        foreach (var entry in list.read_only_view) {
            var self = get_object_from_uri ((entry as Cld.AbstractContainer.Reference).self_uri);
            var reference = get_object_from_uri ((entry as Cld.AbstractContainer.Reference).reference_uri);

            message ("%-30s %s", (self as Cld.Object).uri,
                               (reference as Cld.Object).uri);

            if ((reference != null)) {
                (self as Cld.Container).add (reference);
            }
        }
        debug ("Generate references finished");
    }

    /**
     * Generate internal objects and connections.
     */
    private void setup_controllers () {
        debug ("Generating controllers...");
        /* Get the controllers */
        var controllers = get_children (typeof (Cld.Controller));
        foreach (var controller in controllers.values) {
            (controller as Cld.Controller).generate ();
        }

        /* Connect signals */
        var connectors = get_object_map (typeof (Cld.Connector));
        foreach (var connector in connectors.values) {
            (connector as Cld.Connector).connect_signals ();
        }
        debug ("Generate controllers finished");
    }
}
