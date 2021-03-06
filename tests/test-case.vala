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

/**
 * TestCase was pilfered from libgee
 */

public abstract class Cld.TestCase : GLib.Object {

	private GLib.TestSuite suite;
	private Adaptor[] adaptors = new Adaptor[0];

	public delegate void TestMethod ();

	public TestCase (string name) {
		this.suite = new GLib.TestSuite (name);
	}

	public void add_test (string name, TestMethod test) {
		var adaptor = new Adaptor (name, test, this);
		this.adaptors += adaptor;

		this.suite.add (new GLib.TestCase (adaptor.name,
		                                   adaptor.set_up,
		                                   adaptor.run,
		                                   adaptor.tear_down ));
	}

	public virtual void set_up () {
	}

	public virtual void tear_down () {
	}

	public GLib.TestSuite get_suite () {
		return this.suite;
	}

	private class Adaptor {

		public string name { get; private set; }
		private TestMethod test;
		private TestCase test_case;

		public Adaptor (string name,
		                owned TestMethod test,
		                TestCase test_case) {
			this.name = name;
			this.test = (owned)test;
			this.test_case = test_case;
		}

		public void set_up (void* fixture) {
			this.test_case.set_up ();
		}

		public void run (void* fixture) {
			this.test ();
		}

		public void tear_down (void* fixture) {
			this.test_case.tear_down ();
		}
	}
}
