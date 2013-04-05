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
 * Skeletal implementation of the {@link Port} interface.
 *
 * Contains common code shared by all port implementations.
 */
public abstract class Cld.AbstractPort : AbstractObject, Port {

    /**
     * {@inheritDoc}
     */
    public abstract bool connected { get; }

    /**
     * {@inheritDoc}
     */
    public abstract ulong tx_count { get; }

    /**
     * {@inheritDoc}
     */
    public abstract ulong rx_count { get; }

    /**
     * {@inheritDoc}
     */
    public virtual string byte_count_string {
        owned get {
            string r = "TX: %lu, RX: %lu".printf (tx_count, rx_count);
            return r;
        }
    }

    /**
     * {@inheritDoc}
     */
    public abstract bool open ();

    /**
     * {@inheritDoc}
     */
    public abstract void close ();

    /**
     * {@inheritDoc}
     */
    public abstract void send_byte (uchar byte);

    /**
     * {@inheritDoc}
     */
    public abstract void send_bytes (char[] bytes, size_t size);

    /**
     * {@inheritDoc}
     */
    public abstract bool read_bytes (GLib.IOChannel source, GLib.IOCondition condition);

    /**
     * {@inheritDoc}
     */
    public override string to_string () {
        return "Port";
    }
}
