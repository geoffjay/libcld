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
 * Skeletal implementation of the {@link Channel} interface.
 *
 * Contains common code shared by all channel implementations.
 */
public abstract class Cld.AbstractChannel : Cld.AbstractContainer, Cld.Channel {

    /**
     * Property backing fields.
     */
    protected weak Cld.Device _device;
    protected weak Cld.Task _task;

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
    public virtual Device device {
        get {
            if (_device == null) {
                var devices = get_children (typeof (Cld.Device));
                foreach (var dev in devices.values) {
                    /* this should only happen once */
                    _device = dev as Cld.Device;
                    break;
                }
            }

            return _device;
        }
        set {
            _device = value;
        }
    }

    /**
     * {@inheritDoc}
     */
    public virtual string taskref { get; set; }

    /**
     * {@inheritDoc}
     */
    public virtual Task task {
        get {
            if (_task == null) {
                var tasks = get_children (typeof (Cld.Task));
                foreach (var tsk in tasks.values) {
                    /* this should only happen once */
                    _task = tsk as Cld.Task;
                    break;
                }
            }

            return _task;
        }
        set {
            _task = value;
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
