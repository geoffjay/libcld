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

public class CalibrationTests : ObjectTests {

    public CalibrationTests () {
        base ("Calibration");
        add_test ("[Calibration] default scale factors", test_default_scale);
    }

    public override void set_up () {
        test_object = new Calibration ();
    }

    public override void tear_down () {
        test_object = null;
    }

    private void test_default_scale () {
        var test_calibration = test_object as Calibration;

        // Check the calibration exists
        assert (test_calibration != null);

        stdout.printf ("%s", (test_calibration as Cld.Container).to_string_recursive ());

        // Change the values and then reset to defaults
        test_calibration.set_nth_coefficient (0, -5.0);
        test_calibration.set_nth_coefficient (1, 2.0);

        test_calibration.set_default ();
        assert (test_calibration.get_coefficient (0).value == 0.0);
        assert (test_calibration.get_coefficient (1).value == 1.0);
    }
}
