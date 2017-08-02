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

public class Cld.DummyContainer : Cld.AbstractContainer { }

public class DummyContainerTests : ObjectTests {

    public DummyContainerTests () {
        base ("Container");
        add_test ("[Contaner] Test ID assignment", test_id);
        add_test ("[Contaner] Test add object method", test_add);
        add_test ("[Contaner] Test remove object method", test_remove);
    }

    public override void set_up () {
        test_object = new Cld.DummyContainer ();
    }

    public override void tear_down () {
        test_object = null;
    }

    public void test_id () {
        var test = test_object as Cld.Object;
        test.id = "obj0";

        assert (test != null);
        assert (test.id == "obj0");
    }

    public void test_add () {
        int err = 0;
        var test_container = test_object as Cld.Container;

        var object0 = new Cld.DummyObject ();
        var object1 = new Cld.DummyObject ();

        object0.id = "id0";
        object1.id = "id0";

        try {
            test_container.add (object0);
        } catch (Cld.Error ex) {
            if (ex is Cld.Error.KEY_EXISTS)
                err++;
        }
        assert (test_container.get_objects ().size == 1);

        try {
            test_container.add (object1);
        } catch (Cld.Error ex) {
            if (ex is Cld.Error.KEY_EXISTS)
                err++;
        }

        assert (test_container.get_objects ().size == 1);
        assert (err == 1);
    }

    public void test_remove () {
        var test_container = test_object as Cld.Container;
        var object = new Cld.DummyObject ();
        object.id = "obj0";

        test_container.add (object);
        assert (test_container.get_objects ().size == 1);
        test_container.remove (object);
        assert (test_container.get_objects ().size == 0);
    }
}
