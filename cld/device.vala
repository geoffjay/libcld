
/**
 * Hardware device information and settings.
 */
[GenericAccessors]
public interface Cld.Device :  Cld.Object {

    /**
     *
     */
    public abstract int hw_type { get; set; }

    /**
     *
     */
    public abstract int driver { get; set; }

    /**
     *
     */
    public abstract string description { get; set; }

    /**
     *
     */
    public abstract string filename { get; set; }

    /**
     *
     */
    public abstract int unix_fd { get; set; }

    /**
     * A function to open the device for read and write operations.
     */
    public abstract bool open ();

    /**
     * A function to close the device and disabel read and write operations.
     */
    public abstract bool close ();
}

