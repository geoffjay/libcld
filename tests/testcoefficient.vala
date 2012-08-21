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

public class CoefficientTests : ObjectTests {

    public CoefficientTests () {
        base ("Coefficient");
        add_test ("[Coefficient] ...", test_foo);
    }

    public override void set_up () {
        test_object = new Coefficient ();
    }

    public override void tear_down () {
        test_object = null;
    }

    private void test_foo () {
        var test_coefficient = test_object as Coefficient;

        // Check the Coefficient exists
        assert (test_coefficient != null);

//        test_coefficient.do_something ();
//        assert (test_coefficient. == );
//        assert (test_coefficient. == );
    }
}
