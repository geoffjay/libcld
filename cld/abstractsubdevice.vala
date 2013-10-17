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
 * Skeletal implementation of the {@link SubDevice} interface.
 *
 * Contains common code shared by all subdevice implementations.
 */
public abstract class Cld.AbstractSubDevice : AbstractObject, Cld.SubDevice {

    /**
     * {@inheritDoc}
     */
    public abstract int num { get; set; }

    /**
     *
     */
    public abstract string sdtype { get; set; }

     /**
     * {@inheritDoc}
     */
    public override string to_string () {
        string str_data  = "CldSubDevice\n";
               str_data += " [num  ] : %d\n".printf (num);
               str_data += " [sdtype] : %s\n".printf (sdtype);
        return str_data;
    }
}
