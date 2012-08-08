/**
 * Copyright (C) 2010 Geoff Johnson <geoff.jay@gmail.com>
 *
 * This file is part of libcld.
 *
 * This program is free software; you can redistribute it and/or modify
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

namespace Cld {

    public errordomain CalibrationError {
        KEY_NOT_FOUND
    }

    enum DeviceType {
        VIRTUAL = 0,
        COMEDI,
        MCCHID,
        ADVANTECH;

        public string to_string () {
            switch (this) {
                case VIRTUAL:   return "Virtual";
                case COMEDI:    return "Comedi";
                case MCCHID:    return "Measurement Computing";
                case ADVANTECH: return "Advantech";
                default:        assert_not_reached ();
            }
        }
    }

    enum HardwareType {
        INPUT = 0,
        OUTPUT,
        COUNTER,
        MULTIFUNCTION;

        public string to_string () {
            switch (this) {
                case INPUT:         return "Input";
                case OUTPUT:        return "Output";
                case COUNTER:       return "Counter";
                case MULTIFUNCTION: return "Multi-function";
                default:            assert_not_reached ();
            }
        }
    }

    public abstract class Object : GLib.Object {
        /* properties */
        public abstract string id { get; set; }

        /* overridable methods */
        public abstract string to_string ();

        /* virtual methods */
        public virtual bool equal (Cld.Object a, Cld.Object b) {
            return a.id == b.id;
        }

        public virtual int compare (Cld.Object a) {
            if (id == a.id) {
                return 0;
            } else {
                return 1;
            }
        }

        public virtual void print (FileStream f) {
            f.printf ("%s\n", to_string ());
        }
    }
}
