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
public abstract class Cld.AbstractModule : Cld.AbstractContainer, Cld.Module {

    /**
     * Property backing fields.
     */
    protected weak Cld.Port _port;

    /**
     * {@inheritDoc}
     */
    public virtual bool loaded { get; set; }

    /**
     * {@inheritDoc}
     */
    public virtual string devref { get; set; }

    /**
     * {@inheritDoc}
     */
    public virtual string portref { get; set; }

    /**
     * {@inheritDoc}
     */
    public virtual Port port {
        get {
            if (_port == null) {
                var devices = get_children (typeof (Cld.Port));
                foreach (var dev in devices.values) {
                    /* this should only happen once */
                    _port = dev as Cld.Port;
                    break;
                }
            }

            return _port;
        }
        set {
            _port = value;
        }
    }

    /**
     * {@inheritDoc}
     */
    public abstract bool load ();

    /**
     * {@inheritDoc}
     */
    public abstract void unload ();
}
