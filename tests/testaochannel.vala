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

public class AOChannelTests : ChannelTests {

    public AOChannelTests () {
        base ("AOChannel");
        add_test ("[AOChannel] ...", test_foo);
    }

    public override void set_up () {
        test_object = new AOChannel ();
    }

    public override void tear_down () {
        test_object = null;
    }

    private void test_foo () {
        var test_channel = test_object as AOChannel;

        // Check the channel exists
        assert (test_channel != null);

//        test_channel.do_something ();
//        assert (test_channel. == );
//        assert (test_channel. == );
    }
}
