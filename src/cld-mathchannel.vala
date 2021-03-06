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

using matheval;

/**
 * Math variable extends Virtual channel such that the scaled value returned is
 * the same as the calculated value of the Virtual channel. As a scaleable channel
 * it can be connected to a PID control object, for example.
 */
public class Cld.MathChannel : Cld.VChannel, Cld.Connector, Cld.ScalableChannel {

    /* Property backing fields. */
    private double _scaled_value = 0.0;
    private double _raw_value = 0.0;
    private string _taskref = null;
    private double _calculated_value = 0.0;
    private string? _expression = null;
    private string[]? _variable_names = null;

    /* Evaluator fields */
    /* XXX TBD This should work with ScalableChannel and DataSeries. */
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
     * A list of channel references.
     */
    [Description(nick="Data References", blurb="A list of channel references")]
    public Gee.List<string>? drefs { get; set; }

    /**
     * Mathematical expression to be used to evaluate the variable value.
     * eg. ai01 + ai02 - ds00[20] + ds00[-10]
     * where ds00[-10] is the 11th element counter clockwisein the DataSeries
     * circular buffer. "[" and "]" only apply to DataSeries.
     */
    [Description(nick="Expression", blurb="An algebraic expression")]
    public string? expression {
        get { return _expression; }
        set {
            lock (variable_names) {
                lock (variable_vals) {
                    string str = value;
                    /* Replacement of characters to make expression matheval compatible.*/
                    str = str.replace ("[-", "_n");
                    str = str.replace ("[", "_");
                    str = str.replace ("]", "");
                    str = str.replace ("\n", "");
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

                    /* XXX FIXME disconnect signal that ar already connected */
                    connect_signals ();
                }
            }
        }
    }

    private void locked_calculate () {
        /* Resample variables and return value */
        /*
         *lock (variable_names) {
         *    lock (variable_vals) {
         */
                for (int i = 0; i < _variable_names.length; i++ ) {
                    assert (objects != null);
                    foreach (var object in objects.values) {
                        /*assert (object != null);*/
                        if ((object is Cld.DataSeries || object is Cld.ScalableChannel) && (object != null)) {
                            if (_variable_names [i].contains (object.alias)) {
                                if (object is Cld.DataSeries) {
                                    int n;
                                    double val;
                                    if (get_index_from_name (_variable_names [i], out n)) {
                                        if ((object as DataSeries).get_nth_value (n, out val)) {
                                            variable_vals [i] = val;
                                        }
                                    }
                                } else if (object is Cld.ScalableChannel) {
                                    variable_vals [i] = (object as Cld.ScalableChannel).scaled_value;
                                }
                            }
                        }
                    }
                }
        /*
         *    }
         *}
         */
    }

    [Description(nick="Calculated Value", blurb="The calculated value of the expression")]
    public double calculated_value {
                        /*}*/
        get {
            if (_expression != null) {
                GLib.Func func = this.locked_calculate;

                lock (variable_names) {
                    lock (variable_vals) {
                        locked_map_op (func);
                        _calculated_value = evaluator.evaluate (variable_names, variable_vals);
                    }
                }
                raw_value = _calculated_value;

                return _calculated_value;
            } else {
                debug ("expression must be null");
                raw_value = 0.0;

                return 0.0;
            }
        }
        private set {
            _calculated_value = value;
        }
    }

    /**
     * Calculate value if expression exists or placeholder for dummy channel.
     */
    [Description(nick="Raw Value", blurb="The non-scaled value")]
    public double raw_value {
        get { return _raw_value; }
        set {
            _raw_value = value;
            scaled_value = calibration.apply (_raw_value);
        }
    }

    /**
     * {@inheritDoc}
     */
    [Description(nick="Scaled Value", blurb="The value with scaling applied")]
    public virtual double scaled_value {
        get { return _scaled_value; }
        set {
            _scaled_value = value;
            new_value (id, value);
        }
    }

    /**
     * {@inheritDoc}
     */
    [Description(nick="Calibration Reference", blurb="The URI of the calibration")]
    public virtual string calref { get; set; }

    /**
     * {@inheritDoc}
     */
    private Cld.Calibration _calibration = null;
    [Description(nick="Calibration", blurb="The calibration used to generate a scaled value")]
    public virtual Calibration calibration {
        get {
            if (_calibration == null) {
                Gee.Map<string, Cld.Object> calibrations = get_children (typeof (Cld.Calibration));
                foreach (var cal in calibrations.values) {

                    /* this should only happen once */
                    debug ("this should only happen once");
                    /*return cal as Cld.Calibration;*/
                    _calibration  = cal as Cld.Calibration;
                }
            }

            return _calibration;
            /*return null;*/
        }
        set {
            objects.unset_all (get_children (typeof (Cld.Calibration))) ;
            objects.set (value.id, value);
            _calibration = null;
        }
    }


    /* default constructor */
    construct {
        drefs = new Gee.ArrayList<string> ();
    }

    public MathChannel () {
        /* set defaults */
        set_num (0);;
        //this.devref = "dev0";
        this.tag = "CH0";
        this.desc = "Output Channel";
    }

    public MathChannel.from_xml_node (Xml.Node *node) {
        string value;

        this.node = node;
        if (node->type == Xml.ElementType.ELEMENT_NODE &&
            node->type != Xml.ElementType.COMMENT_NODE) {
            id = node->get_prop ("id");
            //devref = node->get_prop ("ref");
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
                            set_num (int.parse (value));
                            break;
                        case "calref":
                            calref = iter->get_content ();
                            break;
                        case "dref":
                            drefs.add (iter->get_content ());
                            break;
                        case "alias":
                            alias = iter->get_content ();
                            break;
                        default:
                            break;
                    }
                }
            }
        }
        connect_notify ();
    }

    /**
     * Connect all the notify signals that should require the node to update
     */
    private void connect_notify () {
        notify["tag"].connect ((s, p) => {
            //debug ("Property %s changed for %s", p.get_name (), uri);
            update_node ();
        });

        notify["desc"].connect ((s, p) => {
            //debug ("Property %s changed for %s", p.get_name (), uri);
            update_node ();
        });

        notify["expression"].connect ((s, p) => {
            //debug ("Property %s changed for %s", p.get_name (), uri);
            update_node ();
        });

        notify["num"].connect ((s, p) => {
            //debug ("Property %s changed for %s", p.get_name (), uri);
            update_node ();
        });

        notify["subdevnum"].connect ((s, p) => {
            //debug ("Property %s changed to %d for %s", p.get_name (), subdevnum,  uri);
            update_node ();
        });

        notify["calref"].connect ((s, p) => {
            //debug ("Property %s changed for %s", p.get_name (), uri);
            update_node ();
        });

        notify["alias"].connect ((s, p) => {
            //debug ("Property %s changed for %s", p.get_name (), uri);
            update_node ();
        });
    }

    /**
     * Update the XML Node for this object.
     */
    private void update_node () {
        if (node->type == Xml.ElementType.ELEMENT_NODE &&
            node->type != Xml.ElementType.COMMENT_NODE) {
            /* iterate through node children */
            for (Xml.Node *iter = node->children;
                 iter != null;
                 iter = iter->next) {
                if (iter->name == "property") {
                    debug ("property: %s", iter->get_prop ("name"));
                    switch (iter->get_prop ("name")) {
                        case "tag":
                            iter->set_content (tag);
                            break;
                        case "desc":
                            iter->set_content (desc);
                            break;
                        case "expression":
                            iter->set_content (expression);
                            break;
                        case "num":
                            iter->set_content (num.to_string ());
                            break;
                        case "subdevnum":
                            iter->set_content (subdevnum.to_string ());
                            break;
                        case "calref":
                            iter->set_content (calref);
                            break;
                        case "alias":
                            iter->set_content (alias);
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
//        if (expression != null) {
//            for (int i = 0; i < variable_names.length; i++) {
//                Cld.Object obj;
//                string name  = variable_names [i];
//                foreach (string ref_id in objects.keys) {
//                    obj = get_object (ref_id);
//                    if (name.contains (ref_id) && (objects.get (ref_id) is DataSeries)) {
//                        (((obj as DataSeries).channel) as Cld.ScalableChannel).new_value.connect ((id, val) => {
//                        double num = calculated_value;
//                    });
//
//                    } else if (name == ref_id && (objects.get (ref_id) is Cld.ScalableChannel)) {
//                        obj = get_object (ref_id);
//                        (obj as Cld.ScalableChannel).new_value.connect ((id, val) => {
//                            double num = calculated_value;
//                        });
//                    } else {
//                        obj = null;
//                    }
//                    if (obj != null) {
//                        add_object (ref_id, obj);
//                        debug ("Assigning Cld.Object %s to MathChannel %s", name, this.id);
//                    }
//                }
//            }
//        }
        if (expression != null) {
            //for (int i = 0; i < variable_names.length; i++) {
            for (int i = 0; i < 1; i++) {
                var name  = variable_names [i];
                var obj = get_object_from_alias (name);
                if (obj != null) {
                    message ("Assigning Cld.Object %s to MathChannel %s", obj.id, this.id);
                    if (obj is Cld.DataSeries) {
                        (((obj as Cld.DataSeries).channel) as Cld.ScalableChannel).new_value.connect ((id, val) => {
                        double num = calculated_value;
                    });

                    } else if (obj is Cld.ScalableChannel) {
                        (obj as Cld.ScalableChannel).new_value.connect ((id, val) => {
                            double num = calculated_value;
                        });
                    }
                }
            }
        }
    }

    /**
     * {@inheritDoc}
     **/
    public override void set_object_property (string name, Cld.Object object) {
        switch (name) {
            case "calibration":
                if (object is Cld.Calibration) {
                    calibration = object as Cld.Calibration;
                    calref = (object as Cld.Calibration).uri;
                    //debug ("Calibration for %s changed to %s", uri, calibration.uri);
                }
                break;
            default:
                break;
        }
    }

    ~MathChannel () {
        if (objects != null)
            objects.clear ();
    }
}
