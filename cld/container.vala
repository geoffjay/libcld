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
 * A common interface inherited by any object that has its own list of sub
 * objects.
 */
[GenericAccessors]
public interface Cld.Container : Cld.Object {

    /**
     * The map collection of the objects that belong to the container.
     */
    public abstract Gee.Map<string, Object> objects { get; set; }

    /**
     * Add a object to the array list of objects
     *
     * @param object object object to add to the list
     */
    public abstract void add (Object object);

    /**
     * Update the internal object list.
     *
     * @param val List of objects to replace the existing one
     */
    public abstract void update_objects (Gee.Map<string, Object> val);

    /**
     * Search the object list for the object with the given ID
     *
     * @param id ID of the object to retrieve
     * @return The object if found, null otherwise
     */
    public abstract Object? get_object (string id);

    /**
     * Sort the contents of the objects map collection.
     */
    public abstract void sort_objects ();
}
