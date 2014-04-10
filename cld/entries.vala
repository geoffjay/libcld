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
     * XXX It would be preferable for the array to be of a generic type rather
     * than double for the sake of efficient memory useage.
     */
    private Gee.ArrayList<double?> _data;
    public Gee.ArrayList<double?> data {
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
        data = new Gee.ArrayList<double?> ();
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
                    data.add ((channel as ScalableChannel).scaled_value);
                } else if (channel is DChannel) {
                    if ((channel as DChannel).state)
                        data.add (1);
                    else
                        data.add (0);
                }
            }
        }
    }
}

/**
 * Contains data from a single row from the "Experiment" table in a Log database.
 */
public class Cld.ExperimentEntry : Cld.AbstractObject {
    /**
     * {@inheritDoc}
     */
    public override string id { get; set; }
    public int experiment_id { get; set; }
    public string name { get; set; }
    public string start_date { get; set; }
    public string stop_date { get; set; }
    public string start_time { get; set; }
    public string stop_time { get; set; }
    public double log_rate { get; set; }

    public ExperimentEntry () {

    }

    /**
     * {@inheritDoc}
     */
    public override string to_string () {
        string str_data = "id: %s\n".printf (id);
        str_data = "%s%s".printf (str_data, "experiment_id: %d\n".printf (experiment_id));
        str_data = "%s%s".printf (str_data, "name: %s\n".printf (name));

        return str_data;
    }
}

/**
 * Contains data from a single row from the "Channel" table in a Log database.
 * Channels are not accessed directly from Cld because the channel lists can change.
 */
public class Cld.ChannelEntry : Cld.AbstractObject {
    /**
     * {@inheritdoc}
     */
    public override string id { get; set; }
    public int chan_tbl_id { get; set ; }
    public int experiment_id {get; set; }
    public string chan_id { get; set; }
    public string desc { get; set; }
    public string tag { get; set; }
    public string cld_type { get; set; }
    public string expression { get; set; }
    public double coeff_x0 { get; set; }
    public double coeff_x1 { get; set; }
    public double coeff_x2 { get; set; }
    public double coeff_x3 { get; set; }
    public double coeff_x4 { get; set; }

    public ChannelEntry () {

    }

    public override string to_string () {
    string str_data = "id: %s\n".printf (id);
    str_data = "%s%s".printf (str_data, "chan_tbl_id: %d\n".printf (chan_tbl_id));

    return str_data;
    }

}
