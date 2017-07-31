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
 * Hardware device information and settings.
 */
[GenericAccessors]
public interface Cld.Device :  Cld.Object {

    /**
     *
     */
    public abstract Cld.HardwareType hw_type { get; set; }

    /**
     *
     */
    public abstract Cld.DeviceType driver { get; set; }

    /**
     *
     */
    public abstract string description { get; set; }

    /**
     *
     */
    public abstract string filename { get; set; }

    /**
     * A function to open the device for read and write operations.
     */
    public abstract bool open ();

    /**
     * A function to close the device and disabel read and write operations.
     */
    public abstract bool close ();
}

