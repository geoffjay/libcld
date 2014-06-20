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
 * Skeletal implementation of the {@link Object} interface.
 *
 * Contains common code shared by all object implementations.
 */
public abstract class Cld.AbstractObject : GLib.Object, Cld.Object {

    /**
     * {@inheritDoc}
     */
    protected string _id;
    public string id {
            get { return _id; }
            set { _id = value; }
    }

    /**
     * {@inheritDoc}
     */
    protected Cld.Object _parent;
    public weak Cld.Object parent {
            get { return _parent; }
            set { _parent = value; }
    }

    /**
     * {@inheritDoc}
     */
    public abstract string to_string ();

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
        return id.ascii_casecmp (a.id);
    }

    /**
     * {@inheritDoc}
     */
    public virtual void print (FileStream f) {
        f.printf ("%s\n", to_string ());
    }
}
