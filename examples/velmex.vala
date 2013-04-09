using Cld;

class Cld.VelmexExample : GLib.Object {

    private GLib.MainLoop loop;
    //private Cld.Module velmex;
    private Cld.SerialPort port;

    public VelmexExample () {

        loop = new MainLoop();
        //velmex = new VelmexModule ();
        port = new SerialPort ();

        port.id = "ser0";
        port.device = "/dev/ttyUSB0";
        port.baud_rate = 9600;
        port.handshake = SerialPort.Handshake.HARDWARE;

        //(velmex as Cld.VelmexModule).id = "vel0";
        //(velmex as Cld.VelmexModule).port = port;

        Timeout.add (5000, execute_program);
    }

    public void run () {

        //if (!velmex.load ())
            //message ("Failed to load the Velmex module.");

        port.open ();

        var prog = "E PM0,C,SA1M4000,A1M50,I1M300,A1M20,I1M200\r";
        port.send_bytes (prog.to_utf8 (), prog.length);

        loop.run ();
    }

    private bool execute_program () {
        port.send_byte ('R');
        return true;
    }
}

public static int main (string[] args) {

    Cld.VelmexExample ex = new Cld.VelmexExample ();
    ex.run ();

    return 0;
}
