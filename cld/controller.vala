/**
 * libcld
 * Copyright (c) 2014, Geoff Johnson, All rights reserved.
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
 * A common interface inherited by any object that acts as a controller that
 * communicates with other controllers and as the conduit for information
 * between sibling classes.
 */
[GenericAccessors]
public interface Cld.Controller : Cld.Object {
    /**
     * A list of FIFOs for inter-process data transfer.
     * The data are paired a pipe name and file descriptor.
     */
    public abstract Gee.Map<string, int>? fifos { get; set; }

    /**
     * Generate the internal structure and relationships of objects that are
     * contained in a controller.
     */
    public abstract void generate ();
}
