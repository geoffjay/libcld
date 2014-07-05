using Cld;

class Cld.LicorExample : GLib.Object {

    private Cld.Module licor;
    private GLib.MainLoop loop;

    public LicorExample () {

        loop = new MainLoop();
        licor = new LicorModule ();

        var port = new SerialPort ();
        var channels = new Gee.TreeMap<string, Cld.Object> ();

        port.id = "ser0";
        port.device = "/dev/ttyUSB0";
        port.baud_rate = 115200;
        port.handshake = SerialPort.Handshake.HARDWARE;

        for (int i = 0; i < 6; i++) {
            var channel = new Cld.VChannel ();
            channel.id = "lc%d".printf (i);
            channels.set (channel.id, channel);
        }

        (licor as Cld.LicorModule).id = "lic0";
        (licor as Cld.LicorModule).port = port;
        (licor as Cld.LicorModule).channels = channels;

        Timeout.add (1000, print_channels);
    }

    public void run () {

        if (!licor.load ())
            message ("Failed to load the Licor module.");

        loop.run ();

        licor.unload ();
    }

    private bool print_channels () {

        string r = "";

        foreach (var channel in (licor as Cld.LicorModule).channels.values) {
            r += "%f,".printf ((channel as Cld.VChannel).raw_value);
        }
        r = r.substring (0, r.length - 1);
        stdout.printf ("%s\n", r);

        return true;
    }
}

public static int main (string[] args) {

    Cld.LicorExample ex = new Cld.LicorExample ();
    ex.run ();

    return 0;
}
