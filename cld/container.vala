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
 * A common interface inherited by any object that has its own list of sub
 * objects.
 */
[GenericAccessors]
public interface Cld.Container : Cld.Object {

    /**
     * The map collection of the objects that belong to the container.
     */
    public abstract Gee.Map<string, Cld.Object> objects { get; set; }

    /**
     * A list of all of the uri strings to objects in other unowned areas of the
     * object tree that will be added from a higher level.
     */
    public abstract Gee.List<Cld.AbstractContainer.Reference>? ref_list { get; private set; }

    /**
     * Signals that an object has been added.
     */
    public abstract signal void object_added (string id);

    /**
     * Signals that an object has been removed.
     */
    public abstract signal void object_removed (string id);

    /**
     * Add an object to the array list of objects
     *
     * @param object object object to add to the list
     */
    public abstract void add (Cld.Object object) throws Cld.Error;

    /**
     * Remove an object to the array list of objects
     *
     * @param object object object to remove from the list
     */
    public abstract void remove (Cld.Object object);

    /**
     * Update the internal object list.
     *
     * @param val List of objects to replace the existing one
     */
    public abstract void update_objects (Gee.Map<string, Cld.Object> val);


    /**
     * Search the object list for the object with the given ID
     *
     * @param id ID of the object to retrieve
     * @return The object if found, null otherwise
     */
    public abstract Cld.Object? get_object (string id);

    /**
     * Search the object list for the object with the given alias
     *
     * @param alias The alias of the the object to retrieve
     * @return The object it found, null otherwise
     */
    public abstract Cld.Object? get_object_from_alias (string alias);

    /**
     * Retrieves a map of all objects of a certain type.
     *
     * {{{
     *  var sc_map = ctr.get_object_map (typeof (Cld.ScalableChannel));
     * }}}
     *
     * @param type class type to retrieve
     * @return flattened map of all objects of a certain class type
     */
    public abstract Gee.Map<string, Cld.Object> get_object_map (Type type);

    /**
     * Retrieve a map of the children of a certain type.
     *
     * {{{
     *  var children = ctr.get_children (typeof (Cld.ScalableChannel));
     * }}}
     *
     * @param type class type to retrieve
     * @return map of all objects of a certain class type
     */
    public abstract Gee.Map<string, Cld.Object> get_children (Type type);

    /**
     * Sort the contents of the objects map collection.
     */
    public abstract void sort_objects ();

    /**
     * Recursively print the contents of the objects map.
     *
     * @param depth current level of the object tree
     */
    public abstract void print_objects (int depth);

    /**
     * Add a reference to a table of references.
     */
    public abstract void add_ref (string uri);

    /**
     * Retrieve the list of all descendant URIs.
     *
     * @return list of all uri values contained by itself and all descendants.
     */
    public abstract unowned Gee.List<Cld.AbstractContainer.Reference>? get_descendant_ref_list ();

    /**
     * Retrieve a descendant object with its URI
     * @return The object with the given URI
     */
    public abstract Cld.Object? get_object_from_uri (string uri);

    /**
     * Self generate the ref_list property.
     */
    public abstract void generate_ref_list ();

    /**
     * Prints a table of references between objects.
     */
    public abstract void print_ref_list ();
}
