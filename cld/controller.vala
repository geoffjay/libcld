
/**
 * A common interface inherited by any object that acts as a controller that
 * communicates with other controllers and as the conduit for information
 * between sibling classes.
 */
[GenericAccessors]
public interface Cld.Controller : Cld.Object {
    /**
     * A list of FIFOs for inter-process data transfer.
     * The data are paired a pipe name and file descriptor.
     */
    public abstract Gee.Map<string, int>? fifos { get; set; }

    /**
     * Generate the internal structure and relationships of objects that are
     * contained in a controller.
     */
    public abstract void generate ();
}
