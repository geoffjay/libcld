/**
 * Copyright (C) 2014 Geoff Johnson
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
 *  Stephen Roy <sroy1966@gmail.com>
 */

/**
 * A common interface for objects that need to be connected to a signal.
 */
public interface Cld.Connector : Cld.Object {
    /**
     * An abstract method that connects the object to the signals it needs.
     */
    public abstract void connect_signals ();
}

