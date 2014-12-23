
/**
 * A common interface for objects that need to be connected to a signal.
 */
public interface Cld.Connector : Cld.Object {
    /**
     * An abstract method that connects the object to the signals it needs.
     */
    public abstract void connect_signals ();
}

