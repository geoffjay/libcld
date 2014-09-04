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
 *
 * This contains the map of Cld.Objects and handles high level executive
 * tasks or delegates them to the various functional controllers that it contains.
 */
public class Cld.Context : Cld.AbstractContainer {

    /**
     * The Controllers for this Context.
     */
    public Cld.AcquisitionController acquisition_controller;
    public Cld.LogController log_controller;
    public Cld.AutomationController automation_controller;

    /**
     * Default construction.
     */
    public Context () {
        acquisition_controller = new Cld.AcquisitionController ();
        log_controller = new Cld.LogController ();
        automation_controller = new Cld.AutomationController ();
    }

    public Context.from_config (Cld.XmlConfig xml) {
        var builder = new Cld.Builder.from_xml_config (xml);
        objects = builder.objects;

        Cld.debug ("\nCld.Context is generating reference list...\n");
        generate_ref_list ();
        Cld.debug ("\nGenerate reference list finished.\n");

        Cld.debug ("\nCld.Context is generating references ..\n");
        generate_references ();
        Cld.debug ("\nGenerate references finished.\n");

        Cld.debug ("\nCld.Context is generating controllers..\n");
        generate ();
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
            //Cld.debug ("%-30s %s", (self as Cld.Object).uri, (reference as Cld.Object).uri);
            if ((reference != null)) {
                self.add (reference);
            }
        }
    }

    /**
     * Generate internal objects and connections.
     */
    public void generate () {
        /* Get the controllers */
        var controllers = get_children (typeof (Cld.Controller));
        foreach (var control in controllers.values) {
            if (control is Cld.AcquisitionController) {
                acquisition_controller = control as Cld.AcquisitionController;
            } else if (control is Cld.LogController) {
                log_controller = control as Cld.LogController;
            } else if (control is Cld.AutomationController) {
                automation_controller = control as Cld.AutomationController;
            }
        }

        /* Generate FIFOs for log to read from and aquisitions to write to */
        var logs = log_controller.get_children (typeof (Cld.Log));
        foreach (var log in logs.values) {
            /* Generate the filename */
            string fname = "/tmp/libcld_%s".printf (log.uri.hash ().to_string ());
            /* add it to the logs fifo list */
            (log as Cld.Log).fifos.set (fname, -1);
            /* Create the FIFO */
            if (Posix.access (fname, Posix.F_OK) == -1) {
                int res = Posix.mkfifo (fname, 0777);
                if (res != 0) {
                    Cld.error ("Context could not create fifo %s\n", fname);
                }
            }
            acquisition_controller.new_fifo (log as Cld.Log, fname);
        }

        acquisition_controller.generate ();
        log_controller.generate ();
        automation_controller.generate ();
    }

    /**
     * Start a log.
     */
    public void start_log (Cld.Log log) {
        foreach (var fifo in log.fifos.keys) {
            log.start ();
            acquisition_controller.stream_data (fifo);
        }
    }
}
