using Cld;
using Posix;

int main (string[] args) {
    Cld.Pid pid = new Cld.Pid ();

    pid.dt = 1;
    pid.run ();
    GLib.stdout.printf ("PID thread launched.\n");
    sleep (10);
    pid.stop ();
    GLib.stdout.printf ("PID thread killed.\n\n");

    GLib.stdout.printf ("json:\n%s\n", pid.to_json ());

    return (0);
}
