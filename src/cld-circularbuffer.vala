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
 * A fixed size circular buffer (FIFO). XXX Should be made to handle generic data types.
 */

public class Cld.CircularBuffer<G> : GLib.Object {
    /**
     * The maximum number of elements that can be stored in the buffer.
     */
    public uint size { get; set; default = 4096; }

    /**
     * Upper limit alarm level.
     * When number of element in use, a signal will be emitted.
     */
//    private uint _upper;
//    public uint upper {
//        get { return _upper; }
//        set { _upper = value; }
//    }
//
//    public signal void high_level ();

    /**
     * True if buffer is full. Data will be overwritten
     */
    private bool _full;
    public bool full {
        get { return _full; }
        private set { _full = value; }
    }

    /**
     * The index of the first element.
     */
    public uint start { get;  private set; default = 0; }

    /**
     * The index of the last element
     */
    public uint end { get; private set; default = 0; }
    internal G [] buffer;

    public Cld.CircularBuffer.from_size (uint qsize) {
        buffer = new  G [qsize + 1];
        this.size = qsize;
        end = 0;
        start = 0;
    }

    /**
     * Add an element to the end of the buffer.
     * @param val The last element buffer.
     */
    public void write (G val) {
        buffer [end] = val;
        end = (end + 1) % size;
//        if (in_use () == _upper) {
//            high_level ();
//        }
        if (end == start) {
            _full = true;
            //message ("Circular buffer is full. Overwriting data");
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
    public G read () {
        G val = buffer [start];
        start = (start + 1) % size;
        _full = false;

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

    /**
     * Retrieves a copy of an internal data array element.
     *
     * @param index The index of the value to be retrieved.
     * @return The n_th element of the internal data array
     */
    public G peek (uint index) {

        return buffer [index];
    }

}
