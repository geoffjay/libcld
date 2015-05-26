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
 * A common interface for the various channel types.
 */
public interface Cld.Channel : Cld.Container {

    /**
     * The channel number, which sometimes refers to its hardware pin number.
     */
    public abstract int num { get; }

    /**
     * The subdevice number; an integer reference as used by Comedi devices.
     * It would be preferable to not do it this way but works as a temporary
     * solution.
     */
    public abstract int subdevnum { get; set; }

    /**
     * A reference to the device that this channel belongs to, this may be a
     * backwards approach and should be replaced with a Device containing a list
     * of channels.
     */
    public abstract string devref { get; set; }

    /**
     * A reference to the device that the channel belongs to, same comments
     * apply here as they did to the devref.
     */
    public abstract weak Device device { get; set; }

    /**
     * String name of the channel, could be considered to be the channel's
     * PNID label.
     */
    public abstract string tag { get; set; }

    /**
     * Description of the channel's purpose.
     */
    public abstract string desc { get; set; }

    /**
     * A Timestamp to that should be updated when the value or state changes.
     */
    public abstract DateTime timestamp { get; set; }

    /**
     * Raised when the channel has been assigned a new value.
     *
     * FIXME: This should replace non-variant equivalents.
     */
    public abstract signal void __new_value (string id, GLib.Variant value);

    /**
     * @param value The num value of the channel
     */
    public abstract void set_num (int value);
}

/**
 * Analog channel interface class.
 */
public interface Cld.AChannel : Cld.AbstractChannel, Cld.Channel {

    /**
     *
     */
    public abstract double raw_value { get; set; }

    /**
     *
     */
    public abstract double avg_value { get; private set; }

    /*
     * The sample standard deviation
     * http://mathworld.wolfram.com/StandardDeviation.html
     */
    public abstract double ssdev_value { get; private set; }

    /**
     * Relates to the measurement range of the hardware.
     * XXX This should perhaps be abstracted from the channel.
     */
    public abstract int range { get; set; }
}

/**
 * Digital channel interface class.
 */
public interface Cld.DChannel : Cld.AbstractChannel, Cld.Channel {

    /**
     * The binary state of the channel.
     */
    public abstract bool state { get; set; }

    /**
     * Raised when the binary state changed.
     */
    public abstract signal void new_value (string id, bool value);
}

/**
 * Input channel interface class, I is for input not interface.
 */
public interface Cld.IChannel : Cld.AbstractChannel, Cld.Channel {
}

/**
 * Output channel interface class.
 */
public interface Cld.OChannel : Cld.AbstractChannel, Cld.Channel {
}

/**
 * Interface class for all channels that can be scaled based on a calibration.
 */
public interface Cld.ScalableChannel : Cld.AbstractChannel, Cld.Channel {

    /**
     * ID reference to the calibration object.
     */
    public abstract string calref { get; set; }

    /**
     * Calibration object used to calculate the scaled value.
     */
    public abstract weak Cld.Calibration calibration { get; set; }

    /**
     * The scaled value that is calculated using the calibration.
     */
    public abstract double scaled_value { get; private set; }

    /**
     * Raised when a new value has been calculated.
     */
    public abstract signal void new_value (string id, double value);

    /**
     * {@inheritDoc}
     *
     */
    public abstract void set_object_property (string name, Cld.Object object);
}
