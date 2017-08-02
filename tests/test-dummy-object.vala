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

public class Cld.DummyObject : Cld.AbstractObject { }

public class DummyObjectTests : ObjectTests {

    public DummyObjectTests () {
        base ("Object");
        add_test ("[Object] Test ID assignment", test_id);
        add_test ("[Object] Test URI assignment", test_uri);
        add_test ("[Object] Test parent assignment", test_parent);
        add_test ("[Object] Test equal for sorting", test_equal);
        add_test ("[Object] Test compare for sorting", test_compare);
    }

    public override void set_up () {
        test_object = new Cld.DummyObject ();
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

    public void test_uri () {
        test_object.id = "obj0";
        assert (test_object.uri == "/obj0");

        var parent = new Cld.DummyContainer ();
        parent.id = "parent0";
        parent.add (test_object);
        assert (test_object.uri == "/parent0/obj0");
    }

    /* XXX TBD */
    public void test_parent () {
        /* Same as test_uri */
        test_uri ();
    }

    public void test_equal () {
        var test_a = new Cld.DummyObject ();
        var test_b = new Cld.DummyObject ();

        test_a.id = "test0";
        test_b.id = "test0";
        assert (test_a.equal (test_a, test_b));

        test_b.id = "test1";
        assert (!test_a.equal (test_a, test_b));
    }

    public void test_compare () {
        var test_a = new Cld.DummyObject ();
        var test_b = new Cld.DummyObject ();

        test_a.id = "test0";
        test_b.id = "test0";
        assert (test_a.compare (test_b) == 0);

        test_b.id = "test1";
        assert (test_a.compare (test_b) < 0);

        test_a.id = "test1";
        test_b.id = "test0";
        assert (test_a.compare (test_b) > 0);
    }
}
