
/**
 * Skeletal implementation of the {@link Module} interface.
 *
 * Contains common code shared by all module implementations.
 */
public abstract class Cld.AbstractModule : Cld.AbstractContainer, Cld.Module {

    /**
     * {@inheritDoc}
     */
    public virtual bool loaded { get; set; }

    /**
     * {@inheritDoc}
     */
    public virtual string devref { get; set; }

    /**
     * {@inheritDoc}
     */
    public virtual string portref { get; set; }

    /**
     * {@inheritDoc}
     */
    public virtual weak Port port {
        get {
                var ports = get_children (typeof (Cld.Port));
                foreach (var prt in ports.values) {

                    /* this should only happen once */
                    return prt as Cld.Port;
                }

            return null;
        }
        set {
            /* remove all first */
            objects.unset_all (get_children (typeof (Cld.Port)));
            objects.set (value.id, value);
        }
    }

    /**
     * {@inheritDoc}
     */
    public abstract bool load ();

    /**
     * {@inheritDoc}
     */
    public abstract void unload ();
}
