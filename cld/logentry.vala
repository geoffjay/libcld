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
     * DateTime data to use for time stamping log entries.
     */
    public DateTime timestamp;

    /**
     * A list representing a single row of data in a table or file.
     */
    private Gee.ArrayList<string?> _data;
    public Gee.ArrayList<string?> data {
        get { return _data; }
        set { _data = value; }
    }

    /**
     * An entry represented as a string.
     */
    private string _as_string;
    public string as_string {
        get {
            _as_string = this.to_string ();
            return _as_string;
            }
        set { _as_string = value; }
    }

    public LogEntry () {
        data = new Gee.ArrayList<string> ();
    }
    /**
     * {@inheritDoc}
     */
    public override string to_string () {
        string str_data = "<none>\n";
        return str_data;
    }

    public void update (Gee.Map<string, Object> objects) {
        timestamp = new DateTime.now_local ();
        data.clear ();
        foreach (var object in objects.values) {
            if (object is Column) {
                var channel = ((object as Column).channel as Channel);
                if (channel is ScalableChannel) {
                    data.add ((channel as ScalableChannel).scaled_value.to_string ());
                } else if (channel is DChannel) {
                    if ((channel as DChannel).state)
                        data.add ("on");
                    else
                        data.add ("off");
                }
            }
        }
        foreach (var object in objects.values) {
            Cld.debug ("%s ", object.id);
        }
        for (int i = 0; i < data.size; i++) {
            string ref_id = data.get (i);
            Cld.debug ("%s", ref_id);
        }
        Cld.debug ("%s", timestamp.to_string ());
    }
}
