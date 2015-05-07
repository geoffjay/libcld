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
 * Skeletal implementation of the {@link Object} interface.
 *
 * Contains common code shared by all object implementations.
 */
public abstract class Cld.AbstractObject : GLib.Object, Cld.Object {

    /**
     * {@inheritDoc}
     */
    protected string _id;
    [Description(nick="ID", blurb="The ID of this object")]
    public virtual string id {
        get { return _id; }
        set { _id = value; }
    }

    /**
     * {@inheritDoc}
     */
    protected string _uri;
    [Description(nick="URI", blurb="The uniform resource identifier of this object")]
    public virtual string uri {
        get {
            if (parent != null) {
                _uri = "%s/%s".printf (parent.uri, id);
            } else {
                _uri = "/%s".printf (id);
            }

            return _uri;
        }
    }

    /**
     * {@inheritDoc}
     */
    protected Cld.Object _parent;
    public virtual Cld.Object parent {
        get { return _parent; }
        set { _parent = value; }
    }

    /**
     * {@inheritDoc}
     */
    protected string _alias;
    [Description(nick="Alias", blurb="An alternative identifier for the object")]
    public virtual string alias {
        get { return _alias; }
        set { _alias = value; }
    }

    /**
     * The XML Node that corresponds to this.
     */
    public Xml.Node* node;

    /**
     * {@inheritDoc}
     */
    public virtual void set_uri (string uri) {
        _uri = uri;
    }

    /**
     * {@inheritDoc}
     */
    public virtual string to_string () {
        string result = "";
        Type type = get_type ();
        ObjectClass ocl = (ObjectClass)type.class_ref ();

        result += "\nCld.Object.id: %s (%s)\n".printf (id, type.name ());
        result += "\tProperties:\n\n";
        result += "\t%-24s%-35s%-20s%-24s\n\n".printf ("name:", "value:", "value type:", "owner type:");

        foreach (ParamSpec spec in ocl.list_properties ()) {
            string val_string = "";
            Type ptype = spec.value_type;
            string property_name = spec.get_name ();
            Value number = Value (ptype);
            get_property (property_name, ref number);
            val_string = number.strdup_contents ();
            result += "\t%-24s%-35s%-20s%-24s\n".printf (
                spec.get_name (),
                val_string,
                spec.value_type.name (),
                spec.owner_type.name ()
            );
        }
        result += "\n";

        return result;
    }

    /**
     * {@inheritDoc}
     */
    public virtual string to_string_recursive () {
        string result = "";
        Type type = get_type ();
        ObjectClass ocl = (ObjectClass)type.class_ref ();
        result += "\nCld.Object.id: %s (%s)\n".printf (id, type.name ());
        result += "\tProperties:\n\n";
        result += "\t%-24s%-35s%-20s%-24s\n\n".printf ("name:", "value:", "value type:", "owner type:");

        foreach (ParamSpec spec in ocl.list_properties ()) {
            string val_string = "";
            Type ptype = spec.value_type;
            string property_name = spec.get_name ();
            Value number = Value (ptype);
            get_property (property_name, ref number);
            val_string = number.strdup_contents ();
            result += "\t%-24s%-35s%-20s%-24s\n".printf (
                spec.get_name (),
                val_string,
                spec.value_type.name (),
                spec.owner_type.name ()
            );
        }
        result += "\n";

        /* XXX The following code can produce a lot of unwanted output */
        if (this is Cld.Container) {
            foreach (var object in (this as Cld.Container).get_objects().values) {
                if (object != null) {
                    result += (object as Cld.Object).to_string_recursive ();
                }
            }
        }

        return result;
    }

    /**
     * {@inheritDoc}
     */
    public virtual bool equal (Cld.Object a, Cld.Object b) {
        return a.id == b.id;
    }

    /**
     * {@inheritDoc}
     */
    public virtual int compare (Cld.Object a) {
        return this.id.ascii_casecmp (a.id);
    }

    /**
     * {@inheritDoc}
     */
    public virtual void print (FileStream f) {
        f.printf ("%s\n", to_string ());
    }

    /**
     *
     * {@inheritDoc}
     */
    public virtual string get_nickname () {
        string name = get_type ().name ();
        switch (name) {
            case "CldAIChannel":
                return "Analog Input";
            case "CldAOChannel":
                return "Analog Output";
            case "CldAcquisitionController":
                return "Acquisition Controller";
            case "CldAutomationController":
                return "Automation Controller";
            case "CldCalibration":
                return "Calibration";
            case "CldCsvLog":
                return "CSV Log";
            case "CldDataSeries":
                return "Data Series";
            case "CldCoefficient":
                return "Coefficient";
            case "CldColumn":
                return "Log Column";
            case "CldComediDevice":
                return "Comedi Device";
            case "CldComediTask":
                return "Comedi Task";
            case "CldDIChannel":
                return "Digital Input";
            case "CldDOChannel":
                return "Digital Output";
            case "CldSqliteLog":
                return "SQLite Log";
            case "CldLogController":
                return "Log Controller";
            case "CldMathChannel":
                return "Math Channel";
            case "CldMultiplexer":
                return "Multiplexer";
            case "CldProcessValue2":
                return "Process Value";
            case "CldPid2":
                return "PID Controller";
            default:
                return name;
        }
    }

    /**
     * {@inheritDoc}
     */
    public virtual void set_object_property (string name, Cld.Object object) {
        //set_property (name, value);
    }
}
