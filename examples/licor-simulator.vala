using Cld;

class Cld.SerialPortExample : GLib.Object {

    public string received = "";

    public void run () {
        var loop = new MainLoop();
        var port = new SerialPort ();
        int timeout_ms = 100;


        port.id = "ser0";
        port.device = "/dev/ttyUSB0";
        port.baud_rate = 115200;
        port.handshake = SerialPort.Handshake.HARDWARE;

        /* this should really be in a unit test */

        GLib.Log.set_handler("SerialPortExample",
                             LogLevelFlags.LEVEL_DEBUG,
                             GLib.Log.default_handler);

        var parity = SerialPort.Parity.parse ("none");
        message ("Parity [none]: %s", parity.to_string ());

        parity = SerialPort.Parity.parse ("NoNe");
        message ("Parity [NoNe]: %s", parity.to_string ());

        parity = SerialPort.Parity.parse ("oDD");
        message ("Parity [oDD]: %s", parity.to_string ());

        parity = SerialPort.Parity.parse ("MaRK");
        message ("Parity [MaRK]: %s", parity.to_string ());

        parity = SerialPort.Parity.parse ("spacE");
        message ("Parity [spacE]: %s", parity.to_string ());

        /* access mode */
        message ("AccessMode [read andWrite]: %s", (SerialPort.AccessMode.parse ("read andWrite")).to_string ());
        message ("AccessMode [readWRITE]: %s", (SerialPort.AccessMode.parse ("readWRITE")).to_string ());
        message ("AccessMode [Ro]: %s", (SerialPort.AccessMode.parse ("Ro")).to_string ());
        message ("AccessMode [readOnly]: %s", (SerialPort.AccessMode.parse ("readOnly")).to_string ());
        message ("AccessMode [reaD Only]: %s", (SerialPort.AccessMode.parse ("reaD Only")).to_string ());
        message ("AccessMode [WrItE oNlY]: %s", (SerialPort.AccessMode.parse ("WrItE oNlY")).to_string ());

        message ("\n\n%s", port.to_string ());

        port.open ();
        message ("\n\n%s", port.to_string ());

        loop.run ();

        port.close ();

        message ("\n\n%s", port.to_string ());
    }
}

public static int main (string[] args) {

    Cld.SerialPortExample ex = new Cld.SerialPortExample ();

    ex.run ();

    return 0;
}
