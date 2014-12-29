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
    public abstract string uri { get; set; }

    /**
     * A weak reference to the parent object.
     */
    public abstract Cld.Object parent { get; set; }

    /**
     * An alternative identifier for the object.
     */
    public abstract string alias { get; set; }

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
}
