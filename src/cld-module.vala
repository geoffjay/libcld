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
 * A common interface for module type objects like a velmex or licor.
 */
[GenericAccessors]
public interface Cld.Module : Cld.Object {

    /**
     * Whether or not the module has been loaded.
     */
    public abstract bool loaded { get; set; }

    /**
     * Device reference for the module.
     **/
    public abstract string devref { get; set; }

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
