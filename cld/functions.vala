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
     */
    namespace Functions {

        public static Gee.EqualDataFunc get_equal_func_for (GLib.Type t) {
            if (t == typeof (Cld.Object)) {
                return (a, b) => {
                    if ((a as Cld.Object).uri == (b as Cld.Object).uri)
                        return true;
                    else if (a == null || b == null)
                        return false;
                    else
                        return str_equal ((string) (a as Cld.Object).uri,
                                          (string) (b as Cld.Object).uri);
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
            if (t == typeof (Cld.Object)) {
                return (a, b) => {
                    return (a as Cld.Object).id.ascii_casecmp ((b as Cld.Object).id);
                };
            } else {
                return (a, b) => {
                    /* FIXME: implementation needed */
                    return 0;
                };
            }
        }
    }
}
