/**
 * A log file entry class which will be pushed onto the tail of the
 * buffer for log file writes.
 */
public class Cld.LogEntry : Cld.AbstractObject {
    /**
     * {@inheritDoc}
     */
    public override string id { get; set; }

    /**
     * A list representing a single row of data in a table or file.
     */
    private Gee.ArrayList<double?> _entry_data;
    public Gee.ArrayList entry_data {
        get { return _entry_data; }
        set { _entry_data = value; }
    }

    /**
     * An entry represented as a string.
     */
    private string _as_string;
    public string as_string {
        get { return _as_string; }
        set { _as_string = value; }
    }

    public LogEntry () {

    }
    /**
     * {@inheritDoc}
     */
    public override string to_string () {
        string str_data = "<none>\n";
        return str_data;
    }

    public void update () {

    }
}
