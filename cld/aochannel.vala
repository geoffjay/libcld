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
 * Analog output channel used for control and logging.
 */
public class Cld.AOChannel : AbstractChannel, AChannel, OChannel {

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
    public override string devref { get; set; }

    /**
     * {@inheritDoc}
     */
    public override weak Device device { get; set; }

    /**
     * {@inheritDoc}
     */
    public override string tag { get; set; }

    /**
     * {@inheritDoc}
     */
    public override string desc { get; set; }

    /**
     * {@inheritDoc}
     */
    public virtual string calref { get; set; }

    /**
     * {@inheritDoc}
     */
    public virtual weak Calibration calibration { get; set; }

    /**
     * {@inheritDoc}
     */
    public virtual double raw_value { get; set; }

    private double _scaled_value;

    /**
     * {@inheritDoc}
     */
    public virtual double scaled_value {
        get {
            if (calibration != null)
                _scaled_value = calibration.apply (raw_value);
            return _scaled_value;
        }
        private set { _scaled_value = value; }
    }

    /**
     * {@inheritDoc}
     */
    public virtual double avg_value { get; private set; }

    /**
     * Wrong spot to store information about control loop, should move it.
     */
    public bool manual { get; set; }

    /* default constructor */
    public AOChannel () {
        /* set defaults */
        this.num = 0;
        this.devref = "dev0";
        this.tag = "CH0";
        this.desc = "Output Channel";

        raw_value = 0.0;
    }

    public AOChannel.from_xml_node (Xml.Node *node) {
        string val;

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
                        case "num":
                            val = iter->get_content ();
                            num = int.parse (val);
                            break;
                        case "calref":
                            /* this should maybe be an object property,
                             * possibly fix later */
                            calref = iter->get_content ();
                            break;
                        default:
                            break;
                    }
                }
            }
        }
    }

    public override string to_string () {
        return base.to_string ();
    }
}
