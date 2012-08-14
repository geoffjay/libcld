/**
 * Copyright (C) 2010 Geoff Johnson <geoff.jay@gmail.com>
 *
 * This file is part of libcld.
 *
 * libcld is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
 */

using Cld;

public class ObjectTests : TestCase {

	public ObjectTests () {
		base ("Object");
		add_test ("[Object] selected functions", test_selected_functions);
	}

	public override void set_up () {
		test_object = new Object ();
	}

	public override void tear_down () {
		test_object = null;
	}

	public void test_selected_functions () {
		var test = test_object as Object;

		// Check the object exists
		assert (test != null);
	}

    // To add other test methods just perform tasks and assert on the expected
    // values that should have resulted

}
