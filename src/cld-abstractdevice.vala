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
 * Skeletal implementation of the {@link Device} interface.
 *
 * Contains common code shared by all device implementations.
 */
public abstract class Cld.AbstractDevice : Cld.AbstractContainer, Cld.Device {

    /**
     * {@inheritDoc}
     */
    [Description(nick="Hardware Type", blurb="The functional capabilities of the device")]
    public virtual Cld.HardwareType hw_type { get; set; }

    /**
     * {@inheritDoc}
     */
    [Description(nick="Device Type", blurb="Device-specific setup and features")]
    public virtual Cld.DeviceType driver { get; set; }

    /**
     * {@inheritDoc}
     */
    [Description(nick="Description", blurb="A description of the device")]
    public virtual string description { get; set; }

    /**
     * {@inheritDoc}
     */
    [Description(nick="Filename", blurb="The path to the device")]
    public virtual string filename { get; set; }

    /**
     * {@inheritDoc}
     */
    public abstract bool open ();

    /**
     * {@inheritDoc}
     */
    public abstract bool close ();
}
