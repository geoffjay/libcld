const Cld = imports.gi.Cld;

function main() {
    let config = Cld.XmlConfig.with_file_name("examples/cld.xml");
    let context = Cld.Context.from_config(config);

    context.print_objects(0);

    let chan = context.get_object("ai0");

    chan.connect('new-value',
        function(o, event) {
            print(chan.id, "value:", chan.raw_value);
        });

    chan.add_raw_value (0.1);
    chan.add_raw_value (0.2);
    chan.add_raw_value (0.3);

    print(chan.id, "current value:", chan.current_value);
}

main();
