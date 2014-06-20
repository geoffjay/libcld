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
 * Authors:
 *  Geoff Johnson <geoff.jay@gmail.com>
 *  Stepehen Roy <sroy1966@gmail.com>
 */

/**
 * Skeletal implementation of the {@link Controller} interface.
 *
 * Contains common code shared by all controller implementations.
 */

public abstract class Cld.AbstractController : Cld.AbstractContainer, Cld.Controller {

    /**
     * {@inheritDoc}
     */
    public virtual string id { get; set; }

    /**
     * {@inheritDoc}
     */
    private Gee.Map<string, Cld.Object> _objects;
    public virtual Gee.Map<string, Cld.Object> objects {
        get { return (_objects); }
        set { update_objects (value); }
    }

    /**
     * Default construction.
     */
    public AbstractController () {
        _objects = new Gee.TreeMap<string, Cld.Object> ();
    }

    /**
     * {@inheritDoc}
     */
    public abstract void generate ();
}
