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
 * Skeletal implementation of the {@link Channel} interface.
 *
 * Contains common code shared by all channel implementations.
 */
public abstract class Cld.AbstractChannel : Cld.AbstractContainer, Cld.Channel {

    /**
     * {@inheritDoc}
     */
    public virtual int num { get; set; }

    /**
     * {@inheritDoc}
     */
    public virtual int subdevnum { get; set; }

    /**
     * {@inheritDoc}
     */
    public virtual string devref { get; set; }

    /**
     * {@inheritDoc}
     */
    public virtual Cld.Device device {
        get {
            var devices = get_children (typeof (Cld.Device));
            foreach (var dev in devices.values) {

                /* this should only happen once */
                return dev as Cld.Device;
            }

            return null;
        }
        set {
            /* remove all first */
            objects.unset_all (get_children (typeof (Cld.Device)));
            objects.set (value.id, value);
        }
    }

    /**
     * {@inheritDoc}
     */
    public virtual string tag { get; set; }

    /**
     * {@inheritDoc}
     */
    public virtual string desc { get; set; }

    /**
     * {@inheritDoc}
     */
    public virtual DateTime timestamp { get; set; }
}
