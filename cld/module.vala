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
 * A common interface for module type objects like a velmex or licor.
 */
[GenericAccessors]
public interface Cld.Module : Cld.Object {

    /**
     * Whether or not the module has been loaded.
     */
    public abstract bool loaded { get; set; }

    /**
     * Port reference for the module.
     */
    public abstract string portref { get; set; }

    /**
     * A reference to the port that the module belongs to.
     */
    public abstract weak Port port { get; set; }

    /**
     * Load the module and take care of any required setup.
     */
    public abstract bool load ();

    /**
     * Unload the module.
     */
    public abstract void unload ();
}
