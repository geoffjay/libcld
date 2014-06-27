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

/**
 * Skeletal implementation of the {@link Object} interface.
 *
 * Contains common code shared by all object implementations.
 */
public abstract class Cld.AbstractObject : GLib.Object, Cld.Object {

    /**
     * {@inheritDoc}
     */
    protected string _id;
    public virtual string id {
        get { return _id; }
        set { _id = value; }
    }

    /**
     * {@inheritDoc}
     */
    protected string _uri;
    public virtual string uri {
        get {
            if (parent != null)
                _uri = "%s/%s".printf (parent.uri, id);
            else
                _uri = "/%s".printf (id);
            return _uri;
        }
        set { _uri = value; }
    }

    /**
     * {@inheritDoc}
     */
    protected Cld.Object _parent;
    public virtual Cld.Object parent {
        get { return _parent; }
        set { _parent = value; }
    }

    /**
     * Property backing fields.
     */
    protected Gee.List<GLib.GenericArray<string>>? _ref_list = null;
    protected Gee.Map<string, Cld.Object> _objects;

    /**
     * {@inheritDoc}
     */
    public virtual bool has_references { get; private set; default = false; }


    /**
     * {@inheritDoc}
     */
    public virtual Gee.List<GenericArray <string>>? ref_list {
        get {
            return _ref_list;
        }
        private set {
            if (_ref_list == null)
                _ref_list = new Gee.ArrayList<GLib.GenericArray<string>> ();
            else
                _ref_list.clear ();
            _ref_list.add_all (value);
        }
    }

    construct {
        _ref_list = new Gee.ArrayList<GLib.GenericArray<string>> ();
    }

    /**
     * {@inheritDoc}
     */
    public virtual void add_ref (string uri, string ref_type) {
        var ary = new GLib.GenericArray<string> ();
        ary.add (this.uri);
        ary.add (uri);
        ary.add (ref_type);
        _ref_list.add (ary);
        has_references = true;
    }

    private Gee.List<GLib.GenericArray<string>> _tmp_list;

    /**
     * {@inheritDoc}
     */
    public virtual unowned Gee.List<GLib.GenericArray<string>>? get_descendant_ref_list () {
        if ((_ref_list != null) || (_objects != null)) {
            _tmp_list = new Gee.ArrayList<GLib.GenericArray<string>> ();
            /* add own uris if any exist */
            _tmp_list.add_all (_ref_list);
            if (this is Cld.Container) {
                /* add all of the uris for objects that are containers */
                var containers = (this as Cld.Container).get_object_map (typeof (Cld.Container));
                foreach (var container in containers.values) {
                    _tmp_list.add_all ((container as Cld.Object).get_descendant_ref_list ());
                }
            } else {
                _tmp_list.add_all (get_descendant_ref_list ());
            }
            return _tmp_list;
        } else {
            return null;
        }
    }

    /**
     * {@inheritDoc}
     */
    public abstract string to_string ();

    /**
     * {@inheritDoc}
     */
    public virtual bool equal (Cld.Object a, Cld.Object b) {
        return a.id == b.id;
    }

    /**
     * {@inheritDoc}
     */
    public virtual int compare (Cld.Object a) {
        return id.ascii_casecmp (a.id);
    }

    /**
     * {@inheritDoc}
     */
    public virtual void print (FileStream f) {
        f.printf ("%s\n", to_string ());
    }
}
