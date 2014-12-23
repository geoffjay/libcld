
/**
 * A class with methods for managing Cld.Log objects from within a Cld.Context.
 */

public class Cld.AutomationController : Cld.AbstractController {
    /**
     * Default construction
     */
    construct {
        _objects = new Gee.TreeMap<string, Cld.Object> ();
    }

    public AutomationController () {}

    /**
     * Construction using an xml node
     */
    public AutomationController.from_xml_node (Xml.Node *node) {
        string value;

        if (node->type == Xml.ElementType.ELEMENT_NODE &&
            node->type != Xml.ElementType.COMMENT_NODE) {
            id = node->get_prop ("id");
            /* iterate through node children */
            for (Xml.Node *iter = node->children; iter != null; iter = iter->next) {
                if (iter->name == "object") {
                    switch (iter->get_prop ("type")) {
                        case "pid":
                            var pid = new Cld.Pid.from_xml_node (iter);
                            pid.parent = this;
                            try {
                                add (pid);
                            } catch (Cld.Error.KEY_EXISTS e) {
                                error (e.message);
                            }
                            break;
                        case "pid-2":
                            var pid = new Cld.Pid2.from_xml_node (iter);
                            pid.parent = this;
                            try {
                                add (pid);
                            } catch (Cld.Error.KEY_EXISTS e) {
                                error (e.message);
                            }
                            break;
                        default:
                            break;
                    }
                }
            }
        }
    }

    /**
     * {@inheritDoc}
     */
    public override void generate () {
    }
}
