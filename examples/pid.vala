using Cld;
using Posix;

int main (string[] args) {
    var pid = new Cld.Pid ();
    var ai = new AIChannel ();
    var ao = new AOChannel ();

    ai.id = "ai0";
    ao.id = "ao0";

    var cal = new Calibration ();
    ai.calibration = cal;

    var pv = new ProcessValue.full ("pv0", ai);
    var mv = new ProcessValue.full ("pv1", ao);

    pid.add_process_value (pv);
    pid.add_process_value (mv);

    pid.dt = 1;
    pid.run ();
    GLib.stdout.printf ("PID thread launched.\n");
    sleep (10);
    pid.stop ();
    GLib.stdout.printf ("PID thread killed.\n\n");

    GLib.stdout.printf ("json:\n%s\n", pid.to_json ());

    return (0);
}
