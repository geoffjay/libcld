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

    /**
     * {@inheritDoc}
     */
    private Gee.Map<string, Cld.Object> _objects;
    public override Gee.Map<string, Cld.Object> objects {
        get { return (_objects); }
        set { update_objects (value); }
    }

    private Cld.LogController log_controller;
    private Cld.AcquisitionController acquisition_controller;
    private Cld.AutomationController automation_controller;

    construct {
        //_objects = new Gee.TreeMap<string, Cld.Object> ();
    }

    /**
     * Default construction.
     */
    public Context () {
        generate ();
    }

    public Context.from_config (Cld.XmlConfig xml) {
        var builder = new Cld.Builder.from_xml_config (xml);
        objects = builder.objects;
        generate ();
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
     * Connects all object signals where a reference has been requested.
     *
     * XXX not sure if this should actually happen here, or in builder
     */
    public void connect_signals () {
        /*
         *log_controller.request.connect ();
         *acquisition_controller.request.connect ();
         *automation_controller.request.connect ();
         */
    }

    /**
     * Generate refererences to between objects as needed.
     */
    public void generate () {
//        Cld.debug ("Generating Context...\n");
//
//        foreach (var object in objects.values) {
//            if (object is Cld.Log) {
//                Cld.debug ("    Adding Log to LogController: %s", object.id);
//                (log_controller as Cld.Container).add (object as Cld.Object);
//            } else if (object is Cld.Daq) {
//                Cld.debug ("    Adding Daq to AcquisitionController: %s", object.id);
//                (acquisition_controller as Cld.Container).add (object as Cld.Object);
//            } else if (object is Cld.Control) {
//                Cld.debug ("    Adding Control to AutomationController: %s", object.id);
//                (automation_controller as Cld.Container).add (object as Cld.Object);
//            }
//        }
//
//        log_controller.generate ();
//        acquisition_controller.generate ();
//        automation_controller.generate ();
    }

    /**
     * {@inheritDoc}
     */
    public override void update_objects (Gee.Map<string, Cld.Object> val) {
        _objects = val;
    }

    /**
     * {@inheritDoc}
     */
    public override string to_string () {
        return base.to_string ();
    }
}
