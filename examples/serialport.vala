using Cld;

int main (string[] args) {
    //var port = new SerialPort ();

    /* this should really be in a unit test */

    var parity = SerialPort.Parity.parse ("none");
    debug ("Parity [none]: %s", parity.to_string ());

    parity = SerialPort.Parity.parse ("NoNe");
    debug ("Parity [NoNe]: %s", parity.to_string ());

    parity = SerialPort.Parity.parse ("oDD");
    debug ("Parity [oDD]: %s", parity.to_string ());

    parity = SerialPort.Parity.parse ("MaRK");
    debug ("Parity [MaRK]: %s", parity.to_string ());

    parity = SerialPort.Parity.parse ("spacE");
    debug ("Parity [spacE]: %s", parity.to_string ());

    /* access mode */
    debug ("AccessMode [read andWrite]: %s", (SerialPort.AccessMode.parse ("read andWrite")).to_string ());
    debug ("AccessMode [readWRITE]: %s", (SerialPort.AccessMode.parse ("readWRITE")).to_string ());
    debug ("AccessMode [Ro]: %s", (SerialPort.AccessMode.parse ("Ro")).to_string ());
    debug ("AccessMode [readOnly]: %s", (SerialPort.AccessMode.parse ("readOnly")).to_string ());
    debug ("AccessMode [reaD Only]: %s", (SerialPort.AccessMode.parse ("reaD Only")).to_string ());
    debug ("AccessMode [WrItE oNlY]: %s", (SerialPort.AccessMode.parse ("WrItE oNlY")).to_string ());

    return (0);
}
