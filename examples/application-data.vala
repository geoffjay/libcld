using Cld;
using Gee;
using Threads;

/**
 * This is all very plain for now just to get things going.
 */
public class ApplicationData : GLib.Object {

    public string xml_file { get; set; default = "cld.xml"; }
    public bool active { get; set; default = false; }

    /* CLD data */
    public Cld.Builder builder { get; set; }
    public Cld.XmlConfig xml { get; set; }

/*
    private bool _ui_enabled = false;
    public bool ui_enabled {
        get { return _ui_enabled; }
        set {
            _ui_enabled = value;
            if (_ui_enabled)
                ui = new UserInterfaceData (this);
            else
                ui = null;
        }
    }

    private UserInterfaceData _ui;
    public UserInterfaceData ui {
        get { return _ui; }
        set { _ui = value; }
    }

    private Gee.Map<string, Cld.Object>? _ai_channels = null;
    public Gee.Map<string, Cld.Object>? ai_channels {
        get {
            if (_ai_channels == null) {
                _ai_channels = new Gee.TreeMap<string, Cld.Object> ();
                foreach (var channel in builder.channels.values) {
                    if (channel is AIChannel)
                        _ai_channels.set (channel.id, channel);
                }
            }
            return _ai_channels;
        }
        set { _ai_channels = value; }
    }

    private Gee.Map<string, Cld.Object>? _ao_channels = null;
    public Gee.Map<string, Cld.Object>? ao_channels {
        get {
            if (_ao_channels == null) {
                _ao_channels = new Gee.TreeMap<string, Cld.Object> ();
                foreach (var channel in builder.channels.values) {
                    if (channel is AOChannel)
                        _ao_channels.set (channel.id, channel);
                }
            }
            return _ao_channels;
        }
        set { _ao_channels = value; }
    }
*/

    /**
     * Internal thread data for acquisition. Still considering doing this using
     * a HashMap so that one thread per device could be done.
     */
    private bool _acq_active = false;
    public bool acq_active {
        get {
            return _acq_active;
        }
        set {
            _acq_active = value;
        }
    }

    private unowned Thread<void *> thread;
    private Mutex acq_mutex = new Mutex ();

    /* lists and maps of CLD data - ? still req'd ? */

    public ApplicationData () {
        xml = new Cld.XmlConfig.with_file_name (xml_file);
        builder = new Cld.Builder.from_xml_config (xml);
    }

    public ApplicationData.with_xml_file (string xml_file) {
        this.xml_file = xml_file;
        xml = new Cld.XmlConfig.with_file_name (this.xml_file);
        builder = new Cld.Builder.from_xml_config (xml);
    }

    public void run_acquisition () {
        if (!Thread.supported ()) {
            stderr.printf ("Cannot run acquisition without thread support.\n");
            _acq_active = false;
            return;
        }

        if (!_acq_active) {
            var acq_thread = new AcquisitionThread (this);

            try {
                _acq_active = true;
                /* TODO create is deprecated, check compiler warnings */
                thread = Thread.create<void *> (acq_thread.run, true);
            } catch (ThreadError e) {
                stderr.printf ("%s\n", e.message);
                _acq_active = false;
                return;
            }
        }
    }

    public void stop_acquisition () {
        if (_acq_active) {
            _acq_active = false;
            thread.join ();
        }
    }

    public class AcquisitionThread {
        unowned ApplicationData data;

        public AcquisitionThread (ApplicationData data) {
            this.data = data;
        }

        public void * run () {
            Mutex mutex = new Mutex ();
//            acq_func (data);
//            while (data.acq_active) {
            while (true) {
                mutex.lock ();
                Thread.usleep (1000000);
                debug ("acquiring...");
                mutex.unlock ();
            }
//            return null;
        }
    }
}
