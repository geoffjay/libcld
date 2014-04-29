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
    private DateTime _timestamp;
    public DateTime timestamp {
        get {
            TimeZone tz = new TimeZone.local ();
            _timestamp = new DateTime
                (
                tz,                                               // TimeZone
                int.parse (_time_as_string.substring (0, 4)),     // year
                int.parse (_time_as_string.substring (5, 2)),     // month
                int.parse (_time_as_string.substring (8, 2)),     // day
                int.parse (_time_as_string.substring (11, 2)),    // hour
                int.parse (_time_as_string.substring (14, 2)),    // minute
                double.parse (_time_as_string.substring (17, 6))  // seconds
                );

            return _timestamp;
            }
    }

    /**
     * Time difference in microseconds from the start timestamp.
     */
    public int time_us { get; set; }

    /**
     * The timestamp as a string value.
     */
    private string _time_as_string;
    public string time_as_string {
        get {
            _time_as_string = "%s%s".printf (_timestamp.format ("%F %T"),
            ("%.3f".printf (_timestamp.get_seconds () - _timestamp.get_second ())).substring (1, -1));

            return _time_as_string;
            }
        set { _time_as_string = value; }
    }

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
        _timestamp = new DateTime.now_local ();
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
public struct Cld.ExperimentEntry {
    public int id { get; set; }
    public string name { get; set; }
    public string start_date { get; set; }
    public string stop_date { get; set; }
    public string start_time { get; set; }
    public string stop_time { get; set; }
    public double log_rate { get; set; }

    public ExperimentEntry () {

    }

    public string to_string () {
        string str_data = "id: %d\n".printf (id);
        str_data = "%s%s".printf (str_data, "name: %s\n".printf (name));

        return str_data;
    }
}

/**
 * Contains data from a single row from the "Channel" table in a Log database.
 * Channels are not accessed directly from Cld because the channel lists can change.
 */
public struct Cld.ChannelEntry {
    public int id { get; set ; }
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
    public string units { get; set; }

    public ChannelEntry () {

    }

    public string to_string () {
    string str_data = "id: %d\n".printf (id);

    return str_data;
    }

}