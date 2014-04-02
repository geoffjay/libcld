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
 * Skeletal implementation of the {@link Log} interface.
 */
public abstract class Cld.AbstractLog : Cld.AbstractContainer, Cld.Log {

    /**
     * {@inheritDoc}
     */
    public abstract string name { get; set; }

    /**
     * {@inheritDoc}
     */
    public abstract string path { get; set; }

    /**
     * {@inheritDoc}
     */
    public abstract string file { get; set; }

    /**
     * {@inheritDoc}
     */
    public abstract double rate { get; set; }

    /**
     * {@inheritDoc}
     */
    public abstract int dt { get { return (int)(1e3 / rate); } }

    /**
     * {@inheritDoc}
     */
    public abstract bool active { get; set; }

    /**
     * {@inheritDoc}
     */
    public abstract bool is_open { get; set; }

    /**
     * {@inheritDoc}
     */
    public abstract string date_format { get; set; }

    /**
     * {@inheritDoc}
     */
    public abstract Cld.LogEntry entry { get; set; }

    /**
     * {@inheritDoc}
     */
    public abstract void start ();

    /**
     * {@inheritDoc}
     */
    public abstract void stop ();

    /**
     * {@inheritDoc}
     */
    public override string to_string () {
        string str_data  = "CldLog\n";
               str_data += "\tid:   %s\n".printf (id);
               str_data += "\tname: %s\n".printf (name);
               str_data += "\tpath: %s\n".printf (path);
               str_data += "\tfile: %s\n".printf (file);
               str_data += "\trate: %.3f\n".printf (rate);
        return str_data;
    }
}
