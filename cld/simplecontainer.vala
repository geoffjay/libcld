
/**
 * Internal container to use during context construction.
 */
internal class Cld.SimpleContainer : Cld.AbstractContainer {

    internal SimpleContainer () {
        _objects = new Gee.TreeMap<string, Cld.Object> ();
        message ("SimpleContainer ()");
    }
}
