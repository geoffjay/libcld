using Cld;
using Comedi;

int main (string[] args) {
    var dev = new ComediDevice.Device ();
    var name = dev.get_driver_name();
    message ("Driver Name: %s", name );

    return (0);
}
