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
 * A common interface for many of the objects used throughout. This is a near
 * useless comment and should be fixed in the future.
 */
[GenericAccessors]
public interface Cld.Object : GLib.Object {

    /**
     * The identifier for the object.
     */
    public abstract string id { get; set; }

    /**
     * The tree path to the object.
     */
    public abstract string uri { get; }

    /**
     * A weak reference to the parent object.
     */
    public abstract Cld.Container? parent { get; }

    /**
     * An alternative identifier for the object.
     */
    public abstract string alias { get; set; }

    /**
     * Set the uri
     *
     * @param uri the uri of this
     */
    public abstract void set_uri (string uri);

    /**
     * Converts the contents into an output string.
     *
     * @return the contents of the object formatted as a string.
     */
    public abstract string to_string ();

    /**
     * Converts the contents into an output string.
     * Contents of type Container are handled recursively
     *
     * @return the contents of the object formatted as a string.
     */
    public abstract string to_string_recursive ();

    /**
     * Specifies whether the objects provided are equivalent for sorting.
     *
     * @param a one of the objects to use in the comparison.
     * @param b the other object to use in the comparison.
     *
     * @return  ``true`` or ``false`` depending on whether or not the id
     *          parameters match
     */
    public abstract bool equal (Cld.Object a, Cld.Object b);

    /**
     * Compares the object to another that is provided.
     *
     * @param a the object to compare this one against.
     *
     * @return  ``0`` if they contain the same id, ``1`` otherwise
     */
    public abstract int compare (Cld.Object a);

    /**
     * Prints the contents to the stream given.
     */
    public abstract void print (FileStream f);

    /**
     * Get the nickname of the object
     *
     * @return the nickname of this class
     */
    public abstract string get_nickname ();

    /**
     * Set a property that is a Cld.Object
     *
     * @param name The ParamSpec as returned by GLib.ParamSpec.get_name ().
     * @param value The property value to be set.
     *
     */
    public abstract void set_object_property (string name, Cld.Object object);

    /**
     * Set the object parent to the given container.
     *
     * @param parent the parent to assign.
     */
    internal abstract void set_parent (Cld.Container parent);
}
