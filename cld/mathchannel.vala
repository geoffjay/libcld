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

using matheval;

/**
 * Math variable extends Virtual channel such that the scaled value returned is
 * the same as the calculated value of the Virtual channel. As a scaleable channel
 * it can be connected to a PID control object, for example.
 */
public class Cld.MathChannel : Cld.VChannel, Cld.ScalableChannel {

    /* Property backing fields. */
    private double _scaled_value = 0.0;
    private double _raw_value = 0.0;
    private string _taskref = null;
    private double _calculated_value = 0.0;
    private string? _expression = null;
    private string[]? _variable_names = null;

    /* Evaluator fields */
    /* XXX TBD This should work with ScalableChannel asn DataSeries. */
    private Evaluator evaluator = null;

    private double[]? variable_vals;

    /**
     * Names of variables used in expression
     */
    public string[]? variable_names {
        get { return _variable_names; }
        private set { _variable_names = value; }
    }

    /**
     * Mathematical expression to be used to evaluate the variable value.
     * eg. ai01 + ai02 - ds00[20] + ds00[-10]
     * where ds00[-10] is the 11th element counter clockwisein the DataSeries
     * circular buffer. "[" and "]" only apply to DataSeries.
     */
    public override string? expression {
        get { return _expression; }
        set {
            string str = value;
            /* Replacement of characters to make expression matheval compatible.*/
            str = str.replace ("[-", "_n");
            str = str.replace ("[", "_");
            str = str.replace ("]", "");
            /* check if expression is parseable */
            if ( null != ( evaluator = Evaluator.create (str))) {

                /* retain reference to signify we have good expression */
                _expression = str;

                /* generate variable list for this new expression */
                evaluator.get_variables (out _variable_names);
                variable_vals = new double [_variable_names.length];

            } else {
                /* nullify reference to signify we do not have experession */
                _expression = null;
            }
        }
    }

    public double calculated_value {
        get {
            if (_expression != null) {
                /* Resample variables and return value */
                for (int i = 0; i < _variable_names.length; i++ ) {
                    foreach (string ref_id in _objects.keys) {
                        if (_variable_names [i].contains (ref_id) && (_objects.get (ref_id) is DataSeries)) {
                            int n;
                            double val;
                            if (get_index_from_name (_variable_names [i], out n)) {
                                if ((_objects.get (ref_id) as DataSeries).
                                                        get_nth_value (n, out val)) {
                                    variable_vals [i] = val;
                                }
                            }
                        } else if (_objects.get (ref_id) is ScalableChannel) {
                            variable_vals [i] = (_objects.get (ref_id) as ScalableChannel).scaled_value;
                        }
                    }
                }
            _calculated_value = evaluator.evaluate (variable_names, variable_vals);
            new_value (id, _calculated_value);

            return _calculated_value;
            } else {
                return 0.0;
            }
        }
        private set {
            _calculated_value = value;
            new_value (id, value);
        }
    }

    public void add_object (string name, Cld.Object? object) {
        /* Instantiate dummy objects and populate objectss TreeMap */
        _objects.set ( name, (object as Cld.Object) ) ;
    }

    /**
     * Calculate value if expression exists or placeholder for dummy channel.
     */
    public double raw_value {
        get { return _raw_value; }
        set {
            _raw_value = value;
            scaled_value = calibration.apply (_raw_value);
        }
    }

    /**
     * Returns the calculated value. XXX This is not consistent with other channel types
     * and a work around to get the math channel to respond like the others in a particular context.
     */
    public virtual double scaled_value {
        get { return calculated_value; }
        private set {
            _scaled_value = value;
        }
    }

    /**
     * {@inheritDoc}
     */
    public virtual string calref { get; set; }

    /**
     * {@inheritDoc}
     */
    public virtual Calibration calibration {
        get {
            var calibrations = get_children (typeof (Cld.Calibration));
            foreach (var cal in calibrations.values) {

                /* this should only happen once */
                return cal as Cld.Calibration;
            }

            return null;
        }
        set {
            objects.unset_all (get_children (typeof (Cld.Calibration))) ;
            objects.set (value.id, value);
        }
    }


    /* default constructor */
    construct {
        _objects = new Gee.TreeMap <string, Cld.Object> ();
    }

    public MathChannel () {
        /* set defaults */
        this.num = 0;
        this.devref = "dev0";
        this.tag = "CH0";
        this.desc = "Output Channel";
    }

    public MathChannel.from_xml_node (Xml.Node *node) {
        string value;

        if (node->type == Xml.ElementType.ELEMENT_NODE &&
            node->type != Xml.ElementType.COMMENT_NODE) {
            id = node->get_prop ("id");
            devref = node->get_prop ("ref");
            /* iterate through node children */
            for (Xml.Node *iter = node->children;
                 iter != null;
                 iter = iter->next) {
                if (iter->name == "property") {
                    switch (iter->get_prop ("name")) {
                        case "tag":
                            tag = iter->get_content ();
                            break;
                        case "desc":
                            desc = iter->get_content ();
                            break;
                        case "expression":
                            expression = iter->get_content ();
                            break;
                        case "num":
                            value = iter->get_content ();
                            num = int.parse (value);
                            break;
                        case "calref":
                            calref = iter->get_content ();
                            break;
                        case "devref":
                            devref = iter->get_content ();
                            break;
                        default:
                            break;
                    }
                }
            }
        }
    }

    /**
     * Parses a string containing an encoded integer value.
     */
    private bool get_index_from_name (string name, out int n) {
        string substr;
        int start = name.index_of ("_");
        if (start == -1) {

            return false;
        } else {
            substr = name.substring (start + 1, -1);
            if (substr.contains ("n")) {
                substr = substr.replace ("n", "-");
            }
            n = int.parse (substr);
            return true;
        }
    }

    /**
     * XXX This needs more work to get it to work with channel uri values. Not tested yet.
     * Connect signals that trigger updates to the calculated value as a result of an input value change.
     */
    public void connect_signals () {
        if (expression != null) {
            for (int i = 0; i < variable_names.length; i++) {
                Cld.Object obj;
                string name  = variable_names [i];
                foreach (string ref_id in objects.keys) {
                    obj = get_object (ref_id);
                    if (name.contains (ref_id) && (objects.get (ref_id) is DataSeries)) {
                        (((obj as DataSeries).channel) as Cld.ScalableChannel).new_value.connect ((id, val) => {
                        double num = calculated_value;
                    });

                    } else if (name == ref_id && (objects.get (ref_id) is Cld.ScalableChannel)) {
                        obj = get_object (ref_id);
                        (obj as Cld.ScalableChannel).new_value.connect ((id, val) => {
                            double num = calculated_value;
                        });
                    } else {
                        obj = null;
                    }
                    if (obj != null) {
                        add_object (ref_id, obj);
                        Cld.debug ("Assigning Cld.Object %s to MathChannel %s", name, this.id);
                    }
                }
            }
        }
    }

    ~MathChannel () {
        if (objects != null)
            objects.clear ();
    }
}
