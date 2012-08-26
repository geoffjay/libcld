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
