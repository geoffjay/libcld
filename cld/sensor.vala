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
 * A common interface for sensor types.
 */
public interface Cld.Sensor : Cld.Container {

    /**
     * The measurement channel to reference for this sensor
     */
    public abstract string channel_ref { get; set; }

    /**
     * The measurement channel for this sensor
     */
    public abstract Cld.Channel channel { get; set; }

    /**
     * FIXME: Add an appropriate comment
     */
    public abstract double value { get; set; }

    /**
     * FIXME: Add an appropriate comment
     */
    public abstract double threshold_sp { get; set; }

    /**
     * Indicates the value is within the specified tolerance of the set point
     **/
    public abstract bool threshold_alarm_state { get; set; }

    /**
     * The fractional tolerance setting the upper and lower limit on the alarm state
     */
    public abstract double threshold_tolerance { get; set; }

    /**
     * XXX A lot of these properties will just be placeholders until an actual
     *     use for them is found.
     */

    /**
     * FIXME: Add an appropriate comment
     */
    public abstract double sensitivity { get; set; }

    /**
     * FIXME: Add an appropriate comment
     */
    public abstract Cld.Sensor.Range full_scale_range { get; set; }

    /**
     * FIXME: Add an appropriate comment
     */
    public abstract double hysteresis { get; set; }

    /**
     * FIXME: Add an appropriate comment
     */
    public virtual bool has_channel {
        get {
            /* FIXME: May have an impact on performance if checking a lot*/
            return (get_object_map (typeof (Cld.Channel)).size > 1);
        }
    }

    /**
     * Raised when the sensor has crossed the threshold value
     */
    public abstract signal void threshold_alarm (string id, double value);

    /**
     * FIXME: Add an appropriate comment
     */
    public class Range {

        /**
         * The minimum value measurable by the sensor
         */
        public double min { get; set; }

        /**
         * The maximum value measurable by the sensor
         */
        public double max { get; set; }
    }
}
