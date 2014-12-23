
/**
 * Skeletal implementation of the {@link Port} interface.
 *
 * Contains common code shared by all port implementations.
 */
public abstract class Cld.AbstractPort : AbstractObject, Port {

    /**
     * {@inheritDoc}
     */
    public abstract bool connected { get; }

    /**
     * {@inheritDoc}
     */
    public abstract ulong tx_count { get; }

    /**
     * {@inheritDoc}
     */
    public abstract ulong rx_count { get; }

    /**
     * {@inheritDoc}
     */
    public virtual string byte_count_string {
        owned get {
            string r = "TX: %lu, RX: %lu".printf (tx_count, rx_count);
            return r;
        }
    }

    /**
     * {@inheritDoc}
     */
    public abstract bool open ();

    /**
     * {@inheritDoc}
     */
    public abstract void close ();

    /**
     * {@inheritDoc}
     */
    public abstract void send_byte (uchar byte);

    /**
     * {@inheritDoc}
     */
    public abstract void send_bytes (char[] bytes, size_t size);

    /**
     * {@inheritDoc}
     */
    public abstract bool read_bytes (GLib.IOChannel source, GLib.IOCondition condition);
}
