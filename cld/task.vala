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
 * A common interface for task type objects XXX
 */
[GenericAccessors]
public interface Cld.Task : Cld.Object {

   /**
    * Indicates the current status of the task.
    */
    public abstract bool active { get; set; }

    /**
     * Launch the task.
     */
     public abstract void run ();

    /**
     * Stop an active task.
     */
    public abstract void stop ();

    /**
     * Non-blocking sleep thread used by implementing classes that request their
     * data at a timed interval.
     *
     * @param interval delay in ms
     * @param priority the thread priority to use
     */
    public virtual async void nap (uint interval, int priority = GLib.Priority.DEFAULT) {
        GLib.Timeout.add (interval, () => {
            nap.callback ();
            return false;
        }, priority);
        yield;
    }
}

public interface Cld.PollingTask : Cld.AbstractTask, Cld.Task {
}

public interface Cld.StreamingTask : Cld.AbstractTask, Cld.Task {
}
