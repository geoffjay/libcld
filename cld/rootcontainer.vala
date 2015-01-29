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
 * Internal container to use during context construction.
 */
internal class Cld.RootContainer : Cld.AbstractContainer {

    /* Avoid the need to include /ctr uri lookup strings */
    public override string uri {
        get { return ""; }
        set { _uri = value; }
    }

    internal RootContainer () {
        debug ("Construction");
        _objects = new Gee.TreeMap<string, Cld.Object> ();
    }
}
