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

using Cld;

public class FilterTests : ObjectTests {

    public FilterTests () {
        base ("Filter");
        add_test ("[Filter] ...", test_foo);
    }

    public override void set_up () {
        test_object = new Filter ();
    }

    public override void tear_down () {
        test_object = null;
    }

    private void test_foo () {
        var test_filter = test_object as Filter;

        // Check the Filter exists
        assert (test_filter != null);

//        test_filter.do_something ();
//        assert (test_filter. == );
//        assert (test_filter. == );
    }
}
