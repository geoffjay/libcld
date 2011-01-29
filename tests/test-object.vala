using Cld;

int main (string[] args) {
    var test = new App (args[1]);
    test.run ();
    return (0);
}

public class App {
    Cld.Calibration;
    Cld.Channel;
    Cld.Control;
    Cld.Daq;
    Cld.Device;
    Cld.Log;
    Cld.Pid;
    Cld.Xml;
    string test;

    public App (string test) {
        this.test = test;
    }

    public void run () {
        stdout.printf ("%s\n", test);
    }
}
