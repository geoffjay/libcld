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
 * Virtual channel to be used to execute expressions or just as a dummy channel
 * with a settable value.
 */
public class Cld.VChannel : AbstractChannel, ScalableChannel {

    /**
     * {@inheritDoc}
     */
    public override string id { get; set; }

    /**
     * {@inheritDoc}
     */
    public override int num { get; set; }

    /**
     * {@inheritDoc}
     */
    public override int subdevnum {get; set; }

    /**
     * {@inheritDoc}
     */
    public override string devref { get; set; }

    /**
     * {@inheritDoc}
     */
    public override weak Device device { get; set; }

    /**
     * {@inheritDoc}
     */
    public override string taskref { get {
                                        if (_taskref == null)
                                            throw new Cld.Error.NULL_REF ("A taskref has not been set for this virtual channel.");
                                        else
                                            return _taskref;}
                                    set {_taskref = value; }}

    /**
     * {@inheritDoc}
     */
    public override weak Task task { get; set; }

    /**
     * {@inheritDoc}
     */
    public override string tag { get; set; }

    /**
     * {@inheritDoc}
     */
    public override string desc { get; set; }

    /* Evaluator fields */
    private Evaluator evaluator = null;

    /**
     * @deprecated cld-0.2
     */
    private HashTable<string, AIChannel> channels =
        new HashTable<string, AIChannel> (str_hash, str_equal);
    private double[]? channel_vals;

    /**
     * Names of variables used in expression
     */
    public string[]? channel_names {
        get { return _channel_names; }
        private set { _channel_names = value; }
    }

    /* Property backing fields. */
    private double _scaled_value = 0.0;
    private double _raw_value = 0.0;
    private string _taskref = null;
    private double _calculated_value = 0.0;
    private string? _expression = null;
    private string[]? _channel_names = null;

    /**
     * Mathematical expression to be used to evaluate the channel value.
     * @deprecated cld-0.2
     */
    public virtual string? expression {
        get { return _expression; }
        set {
            /* check if expression is parseable */
            if ( null != ( evaluator = Evaluator.create (value))) {

                /* retain reference to signify we have good expression */
                _expression = value;

                /* generate channel list for this new expression */
                evaluator.get_variables (out _channel_names);
                channel_vals = new double[ _channel_names.length ];

            } else {
                /* nullify reference to signify we do not have experession */
                _expression = null;
            }
        }
    }

    /**
     * @deprecated cld-0.2
     */
    public double calculated_value {
        get {
            if (_expression != null) {
                /* Resample channels and return value */
                for (int i = 0; i < _channel_names.length; i++)
                    channel_vals[ i ] =
                        channels.lookup (_channel_names[ i ]).raw_value;
                return evaluator.evaluate ( channel_names, channel_vals );
            } else {
                return 0.0;
            }
        }
        private set { _calculated_value = value; }
    }

    public void add_channel( string name, Object? channel ) {
        /* Instantiate dummy channels and populate channels HashTable */
        channels.insert ( name, (channel as AIChannel) ) ;
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
     * {@inheritDoc}
     */
    public virtual double scaled_value {
        get { return _scaled_value; }
        private set {
            _scaled_value = value;
            new_value (id, value);
        }
    }

    /**
     * {@inheritDoc}
     */
    public virtual string calref { get; set; }

    /**
     * {@inheritDoc}
     */
    public virtual weak Calibration calibration { get; set; }

    /* default constructor */
    public VChannel () {
        /* set defaults */
        this.num = 0;
        this.devref = "dev0";
        this.tag = "CH0";
        this.desc = "Output Channel";
    }

    public VChannel.from_xml_node (Xml.Node *node) {
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
                        case "taskref":
                           /* this should maybe be an object property,
                             * possibly fix later */
                            taskref = iter->get_content ();
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

    ~VChannel () {
        if (channels != null)
            channels.remove_all ();
    }

    public override string to_string () {
        return base.to_string ();
    }
}
