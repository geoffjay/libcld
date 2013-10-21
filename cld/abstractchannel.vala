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
public abstract class Cld.AbstractChannel : AbstractObject, Channel {

    /**
     * {@inheritDoc}
     */
    public abstract int num { get; set; }

    /**
     * {@inheritDoc}
     */
    public abstract int subdevnum { get; set; }

    /**
     * {@inheritDoc}
     */
    public abstract string devref { get; set; }

    /**
     * {@inheritDoc}
     */
    public abstract weak Device device { get; set; }

    /**
     * {@inheritDoc}
     */
    public abstract string taskref { get; set; }

    /**
     * {@inheritdoc}
     */
    public abstract weak Task task { get; set; }

    /**
     * {@inheritDoc}
     */
    public abstract string tag { get; set; }

    /**
     * {@inheritDoc}
     */
    public abstract string desc { get; set; }

    /**
     * {@inheritDoc}
     */
    public override string to_string () {
        string str_data  = "CldChannel\n";
               str_data += " [id  ] : %s\n".printf (id);
               str_data += " [num ] : %d\n".printf (num);
               str_data += " [subdev ] : %d\n".printf (subdevnum);
               str_data += " [dev ] : %s\n".printf (devref);
               str_data += " [tag ] : %s\n".printf (tag);
               str_data += " [desc] : %s\n".printf (desc);
               str_data += " [devref] : %s\n".printf (devref);
               str_data += " [taskref]: %s\n".printf (taskref);
        return str_data;
    }
}
