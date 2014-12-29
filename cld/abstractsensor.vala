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
 * Skeletal implementation of the {@link Sensor} interface.
 *
 * Contains common code shared by all sensor implementations.
 */
public abstract class Cld.AbstractSensor : Cld.AbstractContainer, Cld.Sensor, Cld.Buildable {

    /**
     * {@inheritDoc}
     */
    protected abstract string xml { get; }

    /**
     * {@inheritDoc}
     */
    protected abstract string xsd { get; }

    /**
     * {@inheritDoc}
     */
    public virtual string channel_ref { get; set; }

    /**
     * {@inheritDoc}
     */
    public virtual double value { get; set; }

    /**
     * {@inheritDoc}
     */
    public virtual double threshold_sp { get; set; }

    /**
     * {@inheritDoc}
     */
    public virtual double sensitivity { get; set; }

    /**
     * {@inheritDoc}
     */
    public virtual Cld.Sensor.Range full_scale_range { get; set; }

    /**
     * {@inheritDoc}
     */
    public virtual double hysteresis { get; set; }

    /**
     * {@inheritDoc}
     */
    public abstract void build_from_node (Xml.Node *node) throws GLib.Error;
}
