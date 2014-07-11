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
 *  Stephen Roy <sroy1966@gmail.com>
 */

/**
 * Class use to use as an interface to the library.
 *
 * XXX some of this may not make sense functioning as a buildable object but
 * until more separation is made between those and other library objects
 * the id and to_string will stay and just be ignored.
 */
public class Cld.Context : Cld.AbstractContainer {

    /**
     * The Acquisition Controller for this Context.
     */
    public Cld.AcquisitionController acquisition_controller;

    construct {
        //_objects = new Gee.TreeMap<string, Cld.Object> ();
    }

    /**
     * Default construction.
     */
    public Context () {
    }

    public Context.from_config (Cld.XmlConfig xml) {
        var builder = new Cld.Builder.from_xml_config (xml);
        objects = builder.objects;

        Cld.debug ("\nGenerating reference list...\n");
        generate_ref_list ();
        Cld.debug ("\nGenerating reference list finished.\n");

        Cld.debug ("\nGenerating references ..\n");
        generate_references ();
        Cld.debug ("\nGenerate references finished.\n");

        Cld.debug ("\nGenerating controllers..\n");
        generate ();
        //generate_automation_controller ();
        //generate_log_controller ();
        Cld.debug ("\nGenerate controllers finished.\n");
    }

    /**
     * Destruction.
     *
     * XXX not even sure if this is necessary or if a Gee.Map will clear itself
     */
    ~Context () {
        if (_objects != null)
            _objects.clear ();
    }

    /**
     * Prints a table of references between objects.
     */
    public void print_ref_list () {
        var list = get_descendant_ref_list ();
        foreach (var entry in list.read_only_view) {
            Cld.debug ("%-30s %s", (entry
                as Cld.AbstractContainer.Reference).self_uri,
                (entry as Cld.AbstractContainer.Reference).reference_uri);
        }
    }

    /**
     * Generate references between objects.
     */
    public void generate_references () {
        Cld.Container self;
        Cld.Object reference;
        var list = get_descendant_ref_list ();
        foreach (var entry in list.read_only_view) {
            self = get_object_from_uri ((entry
                as Cld.AbstractContainer.Reference).self_uri)
                as Cld.Container;
            reference = get_object_from_uri ((entry
                as Cld.AbstractContainer.Reference).reference_uri);
            Cld.debug ("%-30s %s", (self as Cld.Object).uri, (reference as Cld.Object).uri);
            if ((reference != null)) {
                self.add (reference);
            }
        }
    }

    /**
     * Generate dependencies that are not
     */
    public void generate () {
        /* Fetch the Acquisition Controller. */
        var controllers = get_children (typeof (Cld.AcquisitionController));
        foreach (var control in controllers.values) {
            acquisition_controller = control as Cld.AcquisitionController;
            break;
        }
    }
}
