
/**
 * Skeletal implementation of the {@link Controller} interface.
 *
 * Contains common code shared by all controller implementations.
 */

public abstract class Cld.AbstractController : Cld.AbstractContainer, Cld.Controller {

    /**
     * {@inheritDoc}
     */
    public virtual Gee.Map<string, int>? fifos { get; set; }

    construct {
        fifos = new Gee.TreeMap<string, int> ();
    }

    /**
     * Default construction.
     */
    //public AbstractController () { }

    /**
     * {@inheritDoc}
     */
    public abstract void generate ();
}
