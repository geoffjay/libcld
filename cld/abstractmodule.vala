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
 * Skeletal implementation of the {@link Module} interface.
 *
 * Contains common code shared by all module implementations.
 */
public abstract class Cld.AbstractModule : AbstractContainer, Module {

    /**
     * {@inheritDoc}
     */
    public abstract bool loaded { get; set; }

    /**
     * {@inheritdoc}
     */
    public abstract string devref { get; set; }

    /**
     * {@inheritDoc}
     */
    public abstract string portref { get; set; }

    /**
     * {@inheritDoc}
     */
    public abstract weak Port port { get; set; }

    /**
     * {@inheritDoc}
     */
    public abstract bool load ();

    /**
     * {@inheritDoc}
     */
    public abstract void unload ();

    /**
     * {@inheritDoc}
     */
    public override string to_string () {
        return "Module";
    }
}
