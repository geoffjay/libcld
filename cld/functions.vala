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

namespace Cld {

    /**
     * Helper functions for equal, hash, and compare to be used with Gee types.
     *
     * Concept and structure lifted from libgee.
     *
     * FIXME: Don't think this is being used correctly, causes SIGSEGV.
     */
    namespace Functions {

        public static Gee.EqualDataFunc get_equal_func_for (GLib.Type t) {
            if (t == typeof (Cld.Object)) {
                return (a, b) => {
                    if ((a as Cld.Object).id == (b as Cld.Object).id)
                        return true;
                    else if (a == null || b == null)
                        return false;
                    else
                        return str_equal ((string) (a as Cld.Object).id,
                                          (string) (b as Cld.Object).id);
                };
            } else {
                return (a, b) => { return direct_equal (a, b); };
            }
        }

        public static Gee.HashDataFunc get_hash_func_for (GLib.Type t) {
            if (t == typeof (Cld.Object)) {
                return (a) => {
                    if (a == null)
                        return (uint)0xdeadbeef;
                    else {
                        /* FIXME: requires implementation in CLD classes */
                        return (uint)0xdeadbeef;
                    }
                };
            } else {
                return (a) => { return direct_hash (a); };
            }
        }

        public static GLib.CompareDataFunc get_compare_func_for (GLib.Type t) {
            if (t == typeof (string)) {
                return (a, b) => {
                    if (a == b)
                        return 0;
                    else if (a == null)
                        return -1;
                    else if (b == null)
                        return 1;
                    else
                        return strcmp ((string) a, (string) b);
                };
            } else if (t.is_a (typeof (Cld.Object))) {
                return (a, b) => {
                    if (a == b)
                        return 0;
                    else if (a == null)
                        return -1;
                    else if (b == null)
                        return 1;
                    else
                        return ((Cld.Object) a).compare ((Cld.Object) b);
                };
            } else {
                return (a, b) => {
                    /* FIXME: implementation needed */
                    return 0;
                };
            }
        }

        [CCode (simple_generics = true)]
        internal class EqualDataFuncClosure<G> {
            public EqualDataFuncClosure(owned Gee.EqualDataFunc<G> func) {
                this.func = (owned)func;
            }
            public Gee.EqualDataFunc<G> func;
            public Gee.EqualDataFunc<G> clone_func () {
                return (a, b) => {return func (a, b);};
            }
        }

        [CCode (simple_generics = true)]
        internal class HashDataFuncClosure<G> {
            public HashDataFuncClosure(owned Gee.HashDataFunc<G> func) {
                this.func = (owned)func;
            }
            public Gee.HashDataFunc<G> func;
            public Gee.HashDataFunc<G> clone_func () {
                return (a) => {return func (a);};
            }
        }

        [CCode (simple_generics = true)]
        internal class CompareDataFuncClosure<G> {
            public CompareDataFuncClosure(owned GLib.CompareDataFunc<G> func) {
                this.func = (owned)func;
            }
            public GLib.CompareDataFunc<G> func;
            public GLib.CompareDataFunc<G> clone_func () {
                return (a, b) => {return func (a, b);};
            }
        }
    }
}
