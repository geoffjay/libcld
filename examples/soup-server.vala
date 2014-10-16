class Cld.SoupServerExample : Cld.Example {

    public override string xml {
        get { return _xml; }
        set { _xml = value; }
    }

    private Soup.Server server;
    private Cld.Calibration cal;

    construct {
        xml = """
            <cld xmlns:cld="urn:libcld">
                <cld:objects>
                    <cld:object id="cal0" type="calibration">
                        <cld:property name="units">Volts</cld:property>
                        <cld:object id="cft0" type="coefficient">
                            <cld:property name="n">0</cld:property>
                            <cld:property name="value">0.000</cld:property>
                        </cld:object>
                        <cld:object id="cft1" type="coefficient">
                            <cld:property name="n">1</cld:property>
                            <cld:property name="value">1.000</cld:property>
                        </cld:object>
                    </cld:object>
                    <cld:object id="ai0" type="channel" ref="/daqctl0/dev0" ctype="analog" direction="input">
                        <cld:property name="tag">IN0</cld:property>
                        <cld:property name="desc">Sample Input</cld:property>
                        <cld:property name="num">0</cld:property>
                        <cld:property name="calref">/cal0</cld:property>
                        <cld:property name="taskref">/daqctl0/dev0/tk0</cld:property>
                    </cld:object>
                </cld:objects>
            </cld>
        """;
    }

    public SoupServerExample () {
        base ();
        /* avoiding fixing the channel for now */
        cal = new Cld.Calibration ();
        server = new Soup.Server (Soup.SERVER_PORT, 8088);
    }

    void xml_handler (Soup.Server server, Soup.Message msg, string path,
                      GLib.HashTable? query, Soup.ClientContext client) {
        string id = "";
        /* get the value for the channel that was requested */
        var pairs = msg.uri.query.split ("&");
        foreach (var pair in pairs) {
            var kv = pair.split ("=");
            if (kv[0] == "id")
                id = kv[1];
        }

        /* doesn't handle any errors in HTTP request */
        message ("Retrieving channel: %s", id);
        var channel = context.get_object (id);
        (channel as Cld.ScalableChannel).calibration = cal;
        var value = (channel as Cld.ScalableChannel).scaled_value;
        string response_text = "<data>%f</data>".printf (value);

        msg.response_headers.append ("Access-Control-Allow-Origin", "*");
        msg.set_response ("text/xml", Soup.MemoryUse.COPY, response_text.data);

        /* make the response different next time */
        (channel as Cld.AIChannel).add_raw_value (value + 0.1);
    }

    void json_handler (Soup.Server server, Soup.Message msg, string path,
                       GLib.HashTable? query, Soup.ClientContext client) {
        string id = "";
        /* get the value for the channel that was requested */
        var pairs = msg.uri.query.split ("&");
        foreach (var pair in pairs) {
            var kv = pair.split ("=");
            if (kv[0] == "id")
                id = kv[1];
        }

        message ("%s", path);

        /* doesn't handle any errors in HTTP request */
        message ("Retrieving channel: %s", id);
        var channel = context.get_object (id);
        (channel as Cld.ScalableChannel).calibration = cal;
        var value = (channel as Cld.ScalableChannel).scaled_value;
        var builder = new Json.Builder ();

        builder.begin_object ();
        builder.set_member_name ("data");
        builder.add_double_value (value);
        builder.end_object ();

        var generator = new Json.Generator ();
        var root = builder.get_root ();
        generator.set_root (root);

        var response_text = "jsonp(%s)".printf (generator.to_data (null));

        message ("JSON Response: %s", response_text);

        msg.status_code = 200;
        msg.response_headers.append ("Access-Control-Allow-Origin", "*");
        msg.set_response ("application/json", Soup.MemoryUse.COPY, response_text.data);

        /* make the response different next time */
        (channel as Cld.AIChannel).add_raw_value (value + 0.1);
    }

    public override void run () {
        base.run ();
        server.add_handler ("/xml", xml_handler);
        server.add_handler ("/json", json_handler);
        /* would want to run_async if wrapped into a buildable Cld object */
        server.run ();
    }
}

int main (string[] args) {

    var ex = new Cld.SoupServerExample ();
    ex.run ();

    return (0);
}
