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
 * A common interface for the various channel types.
 */
public interface Cld.Channel : Cld.Object {
    /* inheritable properties */
    public abstract int num       { get; set; }
    public abstract string devref { get; set; }
    public abstract string tag    { get; set; }
    public abstract string desc   { get; set; }
}

/**
 * Analog channel interface class.
 */
public interface Cld.AChannel : AbstractChannel, Channel {
    public abstract Calibration cal     { get; set; }
    public abstract double value        { get; set; }
    public abstract double scaled_value { get; set; }
    public abstract double avg_value    { get; set; }
}

/**
 * Digital channel interface class.
 */
public interface Cld.DChannel : AbstractChannel, Channel {
    public abstract bool state { get; set; }
}

/**
 * Input channel interface class, I is for input not interface.
 */
public interface Cld.IChannel : AbstractChannel, Channel {
}

/**
 * Output channel interface class.
 */
public interface Cld.OChannel : AbstractChannel, Channel {
}
