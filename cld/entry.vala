/**
 * A log file entry class which will be pushed onto the tail of the
 * buffer for log file writes.
 */
public class Cld.LogEntry : Cld.AbstractObject {

    /**
     * DateTime data to use for time stamping log entries.
     */
    private DateTime _timestamp;
    public DateTime timestamp {
        get { return _timestamp; }
        set { _timestamp = value; }
    }

    /**
     * Time difference in microseconds from the start timestamp.
     */
    public int64 time_us { get; set; }

    /**
     * The timestamp as a string value.
     */
    private string _time_as_string;
    public string time_as_string {
        get {
            _time_as_string = "%s.%06d".printf (timestamp.format ("%FT%H:%M:%S"), timestamp.get_microsecond ());
            return _time_as_string;
        }
        set { _time_as_string = value; }
    }

    /**
     * A map of values representing a single row of channel data in a table or file.
     * The keys are channel uri's and the values are scaled value or digital state.
     */
    private Gee.Map<string, double?> _data;
    public Gee.Map<string, double?> data {
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

    construct {
        _data = new Gee.TreeMap<string, double?> ();
    }

    public LogEntry () {
        timestamp = new DateTime.now_local ();
    }

    /**
     * Construct from serialized data. Timestamp must be in the
     * form YYYY-MM-DDTHH:MM:SS.SSSSSS.
     */
    public LogEntry.from_serial (string msg) {
        int64 year, month, day, hour, minute;
        string yr, mo, dy, hr, mn;
        string message =  (string)msg;
        message = message.chomp ();
        string[] array = message.split_set ("\t ");
        yr = array[0].slice (0, 4);
        mo = array[0].slice (5, 7);
        dy = array[0].slice (8, 10);
        hr = array[0].slice (11, 13);
        mn = array[0].slice (14, 16);
        /**
         * XXX Could not get this to work with int.parse (string str)
         * but this awkward method works (?).
         */
        int64.try_parse (yr, out year);
        int64.try_parse (mo, out month);
        int64.try_parse (dy, out day);
        int64.try_parse (hr, out hour);
        int64.try_parse (mn, out minute);
//        int month = int.parse (array[0].slice (5, 7));
//        int day = int.parse (array[0].slice (8, 10));
//        int hour = int.parse (array[0].slice (11, 13));
//        int minute = int.parse (array[0].slice (14, 16));
        double seconds = double.parse (array[0].slice (17, 26));

        timestamp = new DateTime.local ((int)year, (int)month, (int)day, (int)hour, (int)minute, seconds);

        for (int i = 1; i < array.length - 1; i+=2) {
            double num = double.parse (array[i + 1]);
           _data.set (array[i], (double)num);//XXX ..again, not sure why the cast is needed (?).
        }
    }

//    public void update (Gee.Map<string, Object> objects) {
//        //timestamp = new DateTime.now_local ();
//        int i = 0;
//        data.clear ();
//        foreach (var object in objects.values) {
//            if (object is Column) {
//                var channel = ((object as Column).channel as Channel);
//
//                if (i++ == 0)
//                    timestamp = (channel as Channel).timestamp;
//
//                if (channel is ScalableChannel) {
//                    data.add ((channel as ScalableChannel).scaled_value);
//                } else if (channel is DChannel) {
//                    if ((channel as DChannel).state)
//                        data.add (1);
//                    else
//                        data.add (0);
//                }
//            }
//        }
//    }

    /**
     * Converts an entry to a string that can be written to a FIFO for inter-process
     * communication.
     * @return a string representing the contents of this.
     */
//    public string serialize () {
//        string result = "%s".printf (time_as_string);
//
//        foreach (double datum in data) {
//            result+= "\t%.6f".printf (datum);
//        }
//        result+= "\n";
//
//        return result;
//    }
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

    public ExperimentEntry () { }

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
    public string chan_uri { get; set; }
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

    public ChannelEntry () { }

    public string to_string () {
        string str_data = "id: %d\n".printf (id);
        return str_data;
    }
}
