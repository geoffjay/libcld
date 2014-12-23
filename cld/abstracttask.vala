
/**
 * Skeletal implementation of the {@link Task} interface.
 *
 * Contains common code shared by all task implementations.
 */
public abstract class Cld.AbstractTask : AbstractContainer, Task {

    /**
     * {@inheritDoc}
     **/
     public virtual bool active { get; set; }

    /**
     * {@inheritDoc}
     **/
     public abstract void run ();

    /**
     * {@inheritDoc}
     **/
    public abstract void stop ();

}
