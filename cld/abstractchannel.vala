
/**
 * Skeletal implementation of the {@link Channel} interface.
 *
 * Contains common code shared by all channel implementations.
 */
public abstract class Cld.AbstractChannel : Cld.AbstractContainer, Cld.Channel {

    /**
     * {@inheritDoc}
     */
    public virtual int num { get; set; }

    /**
     * {@inheritDoc}
     */
    public virtual int subdevnum { get; set; }

    /**
     * {@inheritDoc}
     */
    public virtual string devref { get; set; }

    /**
     * {@inheritDoc}
     */
    public virtual Cld.Device device {
        get {
            var devices = get_children (typeof (Cld.Device));
            foreach (var dev in devices.values) {

                /* this should only happen once */
                return dev as Cld.Device;
            }

            return null;
        }
        set {
            /* remove all first */
            objects.unset_all (get_children (typeof (Cld.Device)));
            objects.set (value.id, value);
        }
    }

    /**
     * {@inheritDoc}
     */
    public virtual string tag { get; set; }

    /**
     * {@inheritDoc}
     */
    public virtual string desc { get; set; }

    /**
     * {@inheritDoc}
     */
    public virtual DateTime timestamp { get; set; }
}
