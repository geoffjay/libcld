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

public abstract class ObjectTests : Cld.TestCase {

    public ObjectTests (string name) {
        base (name);
        add_test ("[Object] selected functions", test_selected_functions);
    }

    protected Cld.Object test_object;

    public void test_selected_functions () {
        var test = test_object as Cld.Object;

        // Check the object exists
        assert (test != null);
    }

    // To add other test methods just perform tasks and assert on the expected
    // values that should have resulted

}
