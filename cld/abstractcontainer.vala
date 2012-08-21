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
public abstract class Cld.AbstractContainer : AbstractObject, Container {

    /**
     * {@inheritDoc}
     */
    public abstract Gee.Map<string, Object> objects { get; set; }

    /**
     * {@inheritDoc}
     */
    public abstract void add (Object object);

    /**
     * {@inheritDoc}
     */
    public abstract void update_objects (Gee.Map<string, Object> val);

    /**
     * {@inheritDoc}
     */
    public abstract Object? get_object (string id);
}
