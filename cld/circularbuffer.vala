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
 *  Stephen Roy <sroy1966@gmail.com>
 */

/**
 * A fixed size circular buffer (FIFO). XXX Should be made to handle generic data types.
 */

public class Cld.CircularBuffer : GLib.Object {
    /**
     * The maximum number of elements that can be stored in the buffer.
     */
    public uint size { get; set; default = 4096; }

    /**
     * Upper limit alarm level.
     * When number of element in use, a signal will be emitted.
     */
    private uint _upper;
    public uint upper {
        get { return _upper; }
        set { _upper = value; }
    }

    public signal void high_level ();

    /**
     * The index of the first element.
     */
    public uint start { get;  private set; default = 0; }

    /**
     * The index of the last element
     */
    public uint end { get; private set; default = 0; }
    private ushort [] buffer;

    public Cld.CircularBuffer.from_size (int size) {
        this.size = size;
        buffer = new ushort [size + 1];
        end = 0;
        start = 0;
    }

    /**
     * Add an element to the end of the buffer.
     * @param val The last element buffer.
     */
    public void write (ushort val) {
        buffer [end] = val;
        end = (end + 1) % size;
        if (in_use () == _upper) {
            high_level ();
        }

        if (end == start) {
            Cld.message ("Circular buffer is full. Overwriting data");
            start = (start + 1) % size; /* full, overwrite */
        }
    }

    /**
     * @return true if the buffer is empty.
     */
    public bool is_empty () {
        if (end == start) {

            return true;
        } else {

            return false;
        }
    }

    /**
     * Retrieves an element from the start of the buffer.
     * @return The first element in the buffer.
     */
    public ushort read () {
        ushort val = buffer [start];
        start = (start + 1) % size;

        return val;
   }

    /**
     * Retrieves the total number of elements that are in the buffer.
     * @return The number of slots in the buffer that have data.
     */
    public uint in_use () {
        uint total = 0;

        if (start < end) {
            total = end - start + 1;
        } else if (start > end) {
            total = end + size - start + 1;
        }

        return total;
    }

}
