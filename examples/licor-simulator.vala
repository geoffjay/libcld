using Cld;
using Math;

class Cld.SerialPortExample : GLib.Object {

    public string received = "";
    public double[] data = new double [7];
    public GLib.Rand randy = new Rand ();
    public const int nbits = 24;
    public uint source_id;
    public SerialPort port = new SerialPort ();

    public void run () {
        var loop = new MainLoop();
        uint timeout_ms = 20;

        port.id = "ser0";
        port.device = "/dev/ttyACM1";
        port.baud_rate = 115200;
        port.handshake = SerialPort.Handshake.HARDWARE;

        port.open ();
        source_id = Timeout.add (timeout_ms, send_data_cb);
        loop.run ();

        port.close ();
    }

    public bool send_data_cb () {

        string message = "DATAM\t7564809\t11534981\t18652492\t8951674\0";


        for (int i = 0; i < 7; i++) {
            data[i] = (double) randy.int_range (0, (int) pow (2, nbits));
            message += "%.4f".printf (data[i]);
            if (i < 6)
                message += "\t";
        }

        message += "\r\n";
        stdout.printf ("%s", message);
>>>>>>> 64f165d... Working Licor simulator example.
        port.send_bytes (message.to_utf8 (), message.length);

        return true;
    }
}

public static int main (string[] args) {

    Cld.init (args);
    Cld.SerialPortExample ex = new Cld.SerialPortExample ();

    ex.run ();

    return 0;
}
