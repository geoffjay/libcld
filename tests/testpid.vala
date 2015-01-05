/**
 * libcld
 * Copyright (c) 2014, Geoff Johnson, All rights reserved.
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

public class PidTests : ObjectTests {

    public PidTests () {
        base ("Pid");
        add_test ("[Pid] ...", test_foo);
    }

    public override void set_up () {
        test_object = new Cld.Pid ();
    }

    public override void tear_down () {
        test_object = null;
    }

    private void test_foo () {
        var test_pid = test_object as Cld.Pid;

        // Check the Pid exists
        assert (test_pid != null);

//        test_pid.do_something ();
//        assert (test_pid. == );
//        assert (test_pid. == );
    }
}
