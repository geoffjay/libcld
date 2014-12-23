
/**
 * A common interface for module type objects like a velmex or licor.
 */
[GenericAccessors]
public interface Cld.Module : Cld.Object {

    /**
     * Whether or not the module has been loaded.
     */
    public abstract bool loaded { get; set; }

    /**
     * Device reference for the module.
     **/
    public abstract string devref { get; set; }

    /**
     * Port reference for the module.
     */
    public abstract string portref { get; set; }

    /**
     * A reference to the port that the module belongs to.
     */
    public abstract weak Port port { get; set; }

    /**
     * Load the module and take care of any required setup.
     */
    public abstract bool load ();

    /**
     * Unload the module.
     */
    public abstract void unload ();
}
