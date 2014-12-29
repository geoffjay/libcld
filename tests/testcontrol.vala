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

public class ControlTests : ObjectTests {

    public ControlTests () {
        base ("Control");
        add_test ("[Control] ...", test_foo);
    }

    public override void set_up () {
        test_object = new Control ();
    }

    public override void tear_down () {
        test_object = null;
    }

    private void test_foo () {
        var test_control = test_object as Control;

        // Check the Control exists
        assert (test_control != null);

//        test_control.do_something ();
//        assert (test_control. == );
//        assert (test_control. == );
    }
}
