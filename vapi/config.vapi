/**
 * Constants defined by build system.
 */

[CCode (cheader_filename = "config.h")]
public class Cld.Config {

    /* Package information */

    [CCode (cname = "PACKAGE_VERSION")]
    public static const string PACKAGE_NAME;

    [CCode (cname = "PACKAGE_NAME")]
    public static const string PACKAGE_STRING;

    [CCode (cname = "PACKAGE_STRING")]
    public static const string PACKAGE_VERSION;

    /* Configured paths - these variables are not present in config.h, they are
     * passed to underlying C code as cmd line macros. */

    [CCode (cname = "DATADIR")]
    public static const string DATADIR;

    [CCode (cname = "DEVICEDIR")]
    public static const string DEVICEDIR;

    [CCode (cname = "PKGDATADIR")]
    public static const string PKGDATADIR;

    [CCode (cname = "PKGLIBDIR")]
    public static const string PKGLIBDIR;
}
