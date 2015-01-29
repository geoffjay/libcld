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
 * Skeletal implementation of the {@link Container} interface.
 *
 * Contains common code shared by all container implementations.
 */
public abstract class Cld.AbstractContainer : Cld.AbstractObject, Cld.Container {
    /**
     * Property backing fields.
     */
    protected Gee.Map<string, Cld.Object> _objects;
    protected Gee.List<Cld.AbstractContainer.Reference>? _ref_list = null;

    /**
     * {@inheritDoc}
     */
    public virtual Gee.Map<string, Cld.Object> objects {
        get { return (_objects); }
        set { update_objects (value); }
    }

    /**
     * {@inheritDoc}
     */
    public virtual Gee.List<Cld.AbstractContainer.Reference>? ref_list {
        get {
            return _ref_list;
        }
        private set {
            if (_ref_list == null)
                _ref_list = new Gee.ArrayList<Cld.AbstractContainer.Reference> ();
            else
                _ref_list.clear ();
            _ref_list.add_all (value);
        }
    }

    public class Reference {
        public string self_uri;
        public string reference_uri;
    }

    construct {
        _objects = new Gee.TreeMap<string, Cld.Object> ();
        _ref_list = new Gee.ArrayList<Cld.AbstractContainer.Reference> ();
    }

    /**
     * {@inheritDoc}
     */
    public virtual void add (Cld.Object object) throws Cld.Error {
        assert (object != null);
        assert (objects != null);
        foreach (var key in objects.keys) {
            if (key == object.id) {
                throw new Cld.Error.KEY_EXISTS ("Key %s already exists in %s objects".printf (key, id));

                return;
            }
        }

        objects.set (object.id, object);
        object_added (object.id);
    }

    /**
     * {@inheritDoc}
     */
    public virtual void remove (Cld.Object object) {
        if (objects.unset (object.id)) {
            message ("Removed the object: %s from %s", object.id, id);
            object_removed (object.id);
        }
    }

    /**
     * {@inheritDoc}
     */
    public virtual void update_objects (Gee.Map<string, Cld.Object> val) {
        _objects = val;
    }

    /**
     * {@inheritDoc}
     */
    public virtual Cld.Object? get_object (string id) {
        Cld.Object? result = null;
        if (objects.has_key (id)) {
            result = objects.get (id);
        } else {
            foreach (var object in objects.values) {
                if (object is Cld.Container) {
                    result = (object as Cld.Container).get_object (id);
                    if (result != null) {
                        break;
                    }
                }
            }
        }

        return result;
    }

    /**
     * {@inheritDoc}
     */
    public virtual Cld.Object? get_object_from_alias (string alias) {
        Cld.Object? result = null;
        foreach (var object in objects.values) {
            if (object.alias == alias) {
                result = object;
                break;
            } else if ((object is Cld.DataSeries) && (alias.contains (object.alias + "_"))) {
                result = object;
                break;
            } else if (object is Cld.Container) {
                result = (object as Cld.Container).get_object_from_alias (alias);
                if (result != null) {
                    break;
                }
            }
        }

        return result;
    }

    /**
     * {@inheritDoc}
     */
    public virtual Gee.Map<string, Cld.Object> get_object_map (Type type) {
        Gee.Map<string, Cld.Object> map = new Gee.TreeMap<string, Cld.Object> ();
        //debug ("Retrieve object map of type: %s", type.name ());

        if (objects != null) {
            foreach (var object in objects.values) {
                //debug ("1) uri: %s type: %s", object.uri, type.name ());
                if (object.get_type ().is_a (type)) {
                    debug ("2) uri: %s type: %s", object.uri, type.name ());
                    map.set (object.id, object);
                }

                if (object is Cld.Container) {
                    //debug ("%s is a container", object.id);
                    var sub_map = (object as Cld.Container).get_object_map (type);
                    foreach (var sub_object in sub_map.values) {
                        map.set (sub_object.id, sub_object);
                    }
                }
            }
        }

        return map;
    }

    /**
     * {@inheritDoc}
     */
    public virtual Gee.Map<string, Cld.Object> get_children (Type type) {
        Gee.Map<string, Cld.Object> map = new Gee.TreeMap<string, Cld.Object> ();
        foreach (var object in objects.values) {
            if (object.get_type ().is_a (type))
                map.set (object.id, object);
        }
        return map;
    }

    /**
     * {@inheritDoc}
     */
    public virtual void sort_objects () {
        Gee.List<Cld.Object> map_values = new Gee.ArrayList<Cld.Object> ();

        map_values.add_all (objects.values);
        map_values.sort ((GLib.CompareDataFunc<Cld.Object>?) Cld.Object.compare);
        objects.clear ();
        foreach (Cld.Object object in map_values) {
            objects.set (object.id, object);
        }
    }

    /**
     * {@inheritDoc}
     */
    public virtual void print_objects (int depth = 0) {
        assert (objects != null);
        foreach (var object in objects.values) {
            debug ("%s is type: %s", object.id, object.get_type ().name ());
            string indent = string.nfill (depth * 2, ' ');
            string line = "%s[%s: %s]".printf (indent,
                                               object.get_type ().name (),
                                               object.id);
            string parent = (object.parent == null) ? "" : object.parent.id;
            stdout.printf ("%-40s parent: %-14s uri: %s\n", line, parent, object.uri);
            if ((object is Cld.Container)) {// && (!(this.uri.contains (object.uri)))) {
                    (object as Cld.Container).print_objects (depth + 1);
            }
        }
    }

    /**
     * {@inheritDoc}
     */
    public virtual void add_ref (string uri) {
        /* Add the reference if it is not a descendant of this */
        if (!(this.uri.contains (uri))) {
            var reference = new Cld.AbstractContainer.Reference ();
            reference.self_uri =  this.uri;
            reference.reference_uri = uri;
            _ref_list.add (reference);
        }
    }

    private Gee.List<Cld.AbstractContainer.Reference> _tmp_list;

    /**
     * {@inheritDoc}
     */
    public virtual unowned Gee.List<Cld.AbstractContainer.Reference>? get_descendant_ref_list () {
        _tmp_list = new Gee.ArrayList<Cld.AbstractContainer.Reference> ();
        /* add own uris if any exist */
        _tmp_list.add_all (_ref_list);

        //if (this is Cld.Container) {
            //if ((this as Cld.Container).objects != null) {
            if (objects != null) {
                /* add all of the uris for objects that are containers */
                foreach (var object in objects.values) {
                    if (object is Cld.Container) {
                        _tmp_list.add_all ((object as Cld.Container).get_descendant_ref_list ());
                    }
                }
            }
        //}
        return _tmp_list;
    }

    /**
     * {@inheritDoc}
     */
    public virtual Cld.Object? get_object_from_uri (string uri) {
        Cld.Object? result = null;
        Cld.Container container = this;
        string [] tokens;

        tokens = uri.split ("/");
        foreach (string token in tokens) {
            if ((token != "ctr0") && (token != "")) {
                foreach (var object in container.objects.values) {
                    if ((object as Cld.Object).id == token) {
                        if (object is Container) {
                            container = object as Container;
                        }
                        result = object;
                    }
                }
            }
        }

        return result;
    }

    /**
     * {@inheritDoc}
     */
    public virtual void generate_ref_list () {
        debug ("Generating reference list...");

        if (objects == null)
            return;

        foreach (var object in objects.values) {
            if (object is Cld.Container) {
                (object as Cld.Container).generate_ref_list ();

                Type type = object.get_type ();

                if (type.is_a (typeof (Cld.Channel))) {
                    if (type.is_a (typeof (Cld.MathChannel))) {
                        foreach (var dref in (object as Cld.MathChannel).drefs) {
                            (object as Cld.Container).add_ref (dref);
                        }
                    } else if (type.is_a (typeof (Cld.ScalableChannel))) {
                        (object as Cld.Container).add_ref ((object as Cld.ScalableChannel).calref);
                    }
                } else if (type.is_a (typeof (Cld.Column))) {
                    (object as Cld.Container).add_ref ((object as Cld.Column).chref);
                } else if (type.is_a (typeof (Cld.ComediTask))) {
                    (object as Cld.Container).add_ref ((object as Cld.ComediTask).devref);
                    foreach (var chref in (object as Cld.ComediTask).chrefs) {
                        (object as Cld.Container).add_ref (chref);
                    }
                } else if (type.is_a (typeof (Cld.Sensor))) {
                    if (type.is_a (typeof (Cld.FlowSensor)))
                        (object as Cld.Container).add_ref ((object as Cld.FlowSensor).channel_ref);
                } else if (type.is_a (typeof (Cld.DataSeries))) {
                    (object as Cld.Container).add_ref ((object as Cld.DataSeries).chref);
                } else if (type.is_a (typeof (Cld.Module))) {
                    (object as Cld.Container).add_ref ((object as Cld.Module).devref);
                    (object as Cld.Container).add_ref ((object as Cld.Module).portref);
                } else if (type.is_a (typeof (Cld.Pid2))) {
                    (object as Cld.Container).add_ref ((object as Cld.Pid2).sp_chref);
                } else if (type.is_a (typeof (Cld.ProcessValue))) {
                    (object as Cld.Container).add_ref ((object as Cld.ProcessValue).chref);
                } else if (type.is_a (typeof (Cld.ProcessValue2))) {
                    (object as Cld.Container).add_ref ((object as Cld.ProcessValue2).dsref);
                } else if (type.is_a (typeof (Cld.Multiplexer))) {
                    foreach (var taskref in (object as Cld.Multiplexer).taskrefs) {
                        (object as Cld.Container).add_ref (taskref);
                    }
                } else if (type.is_a (typeof (Cld.SqliteLog))) {
                    (object as Cld.Container).add_ref ((object as Cld.SqliteLog).data_source);
                }
            }
        }

        debug ("Generate reference list finished");
    }

    /**
     * {@inheritDoc}
     */
    public virtual void print_ref_list () {
        var list = get_descendant_ref_list ();
        foreach (var entry in list.read_only_view) {
            stdout.printf ("%-30s %s", (entry
                as Cld.AbstractContainer.Reference).self_uri,
                (entry as Cld.AbstractContainer.Reference).reference_uri);
        }
    }
}
