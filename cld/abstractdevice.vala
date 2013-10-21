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
 * Authors:
 *  Geoff Johnson <geoff.jay@gmail.com>
 *  Steve Roy <sroy1966@gmail.com>
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
    public abstract int hw_type { get; set; }

    /**
     * {@inheritDoc}
     */
    public abstract int driver { get; set; }

    /**
     * {@inheritDoc}
     */
    public abstract string description { get; set; }

    /**
     * {@inheritDoc}
     */
    public abstract string filename { get; set; }

    /**
     * {@inheritDoc}
     */
    public abstract int unix_fd { get; set; }

    /**
     * {@inheritDoc}
     */
    public abstract bool open ();

    /**
     * {@inheritDoc}
     */
    public abstract bool close ();

    /**
     * {@inheritDoc}
     */
    public override string to_string () {
        string str_data  = "CldDevice\n";
               str_data += " [hw_type  ] : %d\n".printf (hw_type);
               str_data += " [driver ] : %d\n".printf (driver);
               str_data += " [description ] : %s\n".printf (description);
               str_data += " [filename ] : %s\n".printf (filename);
               str_data += " [unix_fd] : %d\n".printf (unix_fd);
        return str_data;
    }
}
