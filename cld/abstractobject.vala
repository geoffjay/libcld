/**
 * libcld
 * Copyright (c) 2014, Geoff Johnson, All rights reserved.
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
    public virtual string id {
        get { return _id; }
        set { _id = value; }
    }

    /**
     * {@inheritDoc}
     */
    protected string _uri;
    public virtual string uri {
        get {
            if (parent != null) {
                _uri = "%s/%s".printf (parent.uri, id);
            } else {
                _uri = "/%s".printf (id);
            }

            return _uri;
        }
        set { _uri = value; }
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
            foreach (var object in (this as Cld.Container).objects.values) {
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
}
