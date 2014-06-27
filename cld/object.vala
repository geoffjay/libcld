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

//    /**
//     * A flag indicating whether or not objects need to be added as references
//     * to other unowned areas of the object tree.
//     */
//    public abstract bool has_references { get; private set; }

    /**
     * A list of all of the uri strings to objects in other unowned areas of the
     * object tree that will be added from a higher level.
     */
    public abstract Gee.List<GLib.GenericArray<string>>? ref_list { get; private set; }

    /**
     * Retrieve the map of all descendant URIs.
     *
     * @return map of all uri values contained by itself and all descendants.
     */
    public abstract unowned Gee.List<GLib.GenericArray<string>>? get_descendant_ref_list ();

    /**
     * Converts the contents into an output string.
     *
     * @return the contents of the object formatted as a string.
     */
    public abstract string to_string ();

    /**
     * Specifies whether the objects provided are equivalent for sorting.
     *
     * @param a one of the objects to use in the comparison.
     * @param b the other object to use in the comparison.
     *
     * @return  ``true`` or ``false`` depending on whether or not the id
     *          parameters match
     */
    public abstract bool equal (Object a, Object b);

    /**
     * Compares the object to another that is provided.
     *
     * @param a the object to compare this one against.
     *
     * @return  ``0`` if they contain the same id, ``1`` otherwise
     */
    public abstract int compare (Object a);

    /**
     * Prints the contents to the stream given.
     */
    public abstract void print (FileStream f);
}
