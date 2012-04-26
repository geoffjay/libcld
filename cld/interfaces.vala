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

namespace Cld {

    /**
     * Container:
     *
     * Interface inherited by any object that has its own list of sub objects.
     * - consider changing the name to ObjectContainer for clarity?
     */
    public interface Container : GLib.Object {
        public abstract Gee.Map<string, Cld.Object> objects { get; set; }

        public abstract void add (Cld.Object object);
        public abstract void update_objects (Gee.Map<string, Cld.Object> val);
        public abstract Cld.Object? get_object (string id);
    }
}
