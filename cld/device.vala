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
 * Hardware device information and settings.
 */
[GenericAccessors]
public interface Cld.Device :  GLib.Object {
    /**
     * The XXX.
     */
    public abstract int hw_type { get; set; }

    /**
     */
    public abstract int driver { get; set; }

    /**
     */
    public abstract string description { get; set; }

    /**
     */
    public abstract string filename { get; set; }

    /**
     */
    public abstract int unix_fd { get; set; }
    /**
/**
 * A function to open the device for read and write operations.
 */
    public abstract bool open ();

    /**
     * A function to close the device and disabel read and write operations.
    */
    public abstract bool close ();
}

