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
    public virtual int hw_type { get; set; }

    /**
     * {@inheritDoc}
     */
    public virtual int driver { get; set; }

    /**
     * {@inheritDoc}
     */
    public virtual string description { get; set; }

    /**
     * {@inheritDoc}
     */
    public virtual string filename { get; set; }

    /**
     * {@inheritDoc}
     */
    public virtual int unix_fd { get; set; }

    /**
     * {@inheritDoc}
     */
    public abstract bool open ();

    /**
     * {@inheritDoc}
     */
    public abstract bool close ();
//
//    /**
//     * {@inheritDoc}
//     */
//    public override string to_string () {
//        string str_data  = "CldDevice\n";
//               str_data += " [hw_type  ] : %d\n".printf (hw_type);
//               str_data += " [driver ] : %d\n".printf (driver);
//               str_data += " [description ] : %s\n".printf (description);
//               str_data += " [filename ] : %s\n".printf (filename);
//               str_data += " [unix_fd] : %d\n".printf (unix_fd);
//        return str_data;
//    }
}
