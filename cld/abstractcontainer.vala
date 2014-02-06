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
 * Skeletal implementation of the {@link Container} interface.
 *
 * Contains common code shared by all container implementations.
 */
public abstract class Cld.AbstractContainer : Cld.AbstractObject, Cld.Container {

    /**
     * {@inheritDoc}
     */
    public abstract Gee.Map<string, Cld.Object> objects { get; set; }

    /**
     * {@inheritDoc}
     */
    public virtual void add (Cld.Object object) {
        objects.set (object.id, object);
        object_added (object.id);
    }

    /**
     * {@inheritDoc}
     */
    public virtual void remove (Cld.Object object) {
        if (objects.unset (object.id) {
            Cld.debug ("Removed the object: %s", object.id);
            object_removed (object.id);
        }
    }

    /**
     * {@inheritDoc}
     */
    public abstract void update_objects (Gee.Map<string, Cld.Object> val);

    /**
     * {@inheritDoc}
     */
    public virtual Cld.Object? get_object (string id) {
        Cld.Object? result = null;

        if (objects.has_key (id)) {
            result = objects.get (id);
        } else {
            foreach (var object in objects.values) {
                if (object is Container) {
                    result = (object as Container).get_object (id);
                    if (result != null) {
                        break;
                    }
                }
            }
        }

        return result;
    }

    /**
     * {@inheritDoc}
     */
    public virtual void sort_objects () {
        Gee.List<Cld.Object> map_values = new Gee.ArrayList<Cld.Object> ();

        map_values.add_all (objects.values);
        map_values.sort ((GLib.CompareFunc) Cld.Object.compare);
        objects.clear ();
        foreach (Cld.Object object in map_values) {
            objects.set (object.id, object);
        }
    }
}
