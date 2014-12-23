
/**
 * Class use to use as an interface to the library.
 *
 * XXX some of this may not make sense functioning as a buildable object but
 * until more separation is made between those and other library objects
 * the id and to_string will stay and just be ignored.
 *
 * This contains the map of Cld.Objects and handles high level executive
 * tasks or delegates them to the various functional controllers that it contains.
 */
public class Cld.Context : Cld.AbstractContainer {

    /**
     * Logging controller.
     */
    public Cld.LogController log_controller;

    /**
     * Acquisition controller.
     */
    public Cld.AcquisitionController acquisition_controller;

    /**
     * Automation controller.
     */
    public Cld.AutomationController automation_controller;

    /**
     * Default construction.
     */
    public Context () {
        acquisition_controller = new Cld.AcquisitionController ();
        log_controller = new Cld.LogController ();
        automation_controller = new Cld.AutomationController ();
    }

    public Context.from_config (Cld.XmlConfig xml) {
        var builder = new Cld.Builder.from_xml_config (xml);
        objects = builder.objects;

        message ("Generating reference list...");
        generate_ref_list ();
        message ("Generate reference list finished");

        message ("Generating references...");
        generate_references ();
        message ("Generate references finished");

        message ("Generating controllers...");
        generate ();
        message ("Generate controllers finished");
    }

    /**
     * Destruction.
     *
     * XXX not even sure if this is necessary or if a Gee.Map will clear itself
     */
    ~Context () {
        if (_objects != null)
            _objects.clear ();
    }

    /**
     * Prints a table of references between objects.
     */
    public void print_ref_list () {
        var list = get_descendant_ref_list ();
        foreach (var entry in list.read_only_view) {
            message ("%-30s %s", (entry
                as Cld.AbstractContainer.Reference).self_uri,
                (entry as Cld.AbstractContainer.Reference).reference_uri);
        }
    }

    /**
     * Generate references between objects.
     */
    public void generate_references () {
        Cld.Container self;
        Cld.Object reference;
        var list = get_descendant_ref_list ();

        foreach (var entry in list.read_only_view) {
            self = get_object_from_uri ((entry
                as Cld.AbstractContainer.Reference).self_uri)
                as Cld.Container;
            reference = get_object_from_uri ((entry
                as Cld.AbstractContainer.Reference).reference_uri);
//            message ("%-30s %s", (self as Cld.Object).uri, (reference as Cld.Object).uri);
            if ((reference != null)) {
                self.add (reference);
            }
        }
    }

    /**
     * Generate internal objects and connections.
     */
    public void generate () {
        /* Get the controllers */
        var controllers = get_children (typeof (Cld.Controller));
        foreach (var controller in controllers.values) {
            if (controller is Cld.AcquisitionController) {
                acquisition_controller = controller as Cld.AcquisitionController;
                //acquisition_controller.generate ();
            } else if (controller is Cld.LogController) {
                log_controller = controller as Cld.LogController;
                log_controller.generate ();
            } else if (controller is Cld.AutomationController) {
                automation_controller = controller as Cld.AutomationController;
                automation_controller.generate ();
            }

            (controller as Cld.Controller).generate ();
        }

        /* Connect signals */
        var connectors = get_object_map (typeof (Cld.Connector));
        foreach (var connector in connectors.values) {
            (connector as Cld.Connector).connect_signals ();
        }
    }
}
