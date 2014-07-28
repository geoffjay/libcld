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
 * Class use to use as an interface to the library.
 *
 * XXX some of this may not make sense functioning as a buildable object but
 * until more separation is made between those and other library objects
 * the id and to_string will stay and just be ignored.
 */
public class Cld.Context : Cld.AbstractContainer {

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
     * Add FIFOS to a Cld.Log.
     * XXX This method is quite cumbersome and should be simplified.
     */
    public void add_fifos (Cld.Log log) {
        var daq_map = get_object_map (typeof (Cld.Daq));

        foreach (var daq in daq_map.values) {
            var device_map = (daq as Cld.Container).get_object_map (typeof (Cld.Device));
            foreach (var device in device_map.values) {
                var task_map = (device as Cld.Container).get_object_map (typeof (Cld.Task));
                foreach (var task in task_map.values) {
                    if (task is Cld.ComediTask) {
                        /* Request a FIFO and add it to fifos */
                        int fd;
                        string fname = (task as Cld.ComediTask).connect_fifo (log.id, out fd);
                        log.fifos.set (fname, fd);
                    }
                }
            }
        }
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
}
