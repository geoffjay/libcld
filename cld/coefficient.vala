
/**
 * A single nth coefficient to be used to make up a calibration/scale.
 */
public class Cld.Coefficient : AbstractObject {
    public int             n     { get; set; }
    public double          value { get; set; }

    public Coefficient () {
        id = "cft0";
        n = 0;
        value = 0.0;
    }

    public Coefficient.with_data (string id, int n, double value) {
        this.id = id;
        this.n = n;
        this.value = value;
        connect_signals ();
    }

    public Coefficient.from_xml_node (Xml.Node *node) {
        string val;
        this.node = node;

        if (node->type == Xml.ElementType.ELEMENT_NODE &&
            node->type != Xml.ElementType.COMMENT_NODE) {
            id = node->get_prop ("id");
            /* iterate through node children */
            for (Xml.Node *iter = node->children;
                 iter != null;
                 iter = iter->next) {
                if (iter->name == "property") {
                    /* no defined properties yet */
                    switch (iter->get_prop ("name")) {
                        case "n":
                            val = iter->get_content ();
                            n = int.parse (val);
                            break;
                        case "value":
                            val = iter->get_content ();
                            value = double.parse (val);
                            break;
                        default:
                            break;
                    }
                }
            }
        }
        connect_signals ();
    }

    /**
     * Connect all the notify signals that should require the node to update
     */
    private void connect_signals () {
        notify["n"].connect ((s, p) => {
            message ("Property %s changed for %s", p.get_name (), uri);
            update_node ();
        });

        notify["value"].connect ((s, p) => {
            message ("Property %s changed for %s", p.get_name (), uri);
            update_node ();
        });
    }

    /**
     * Update the XML Node for this object.
     */
    private void update_node () {
        if (node->type == Xml.ElementType.ELEMENT_NODE &&
            node->type != Xml.ElementType.COMMENT_NODE) {
            /* iterate through node children */
            for (Xml.Node *iter = node->children;
                 iter != null;
                 iter = iter->next) {
                if (iter->name == "property") {
                    switch (iter->get_prop ("name")) {
                        case "n":
                            iter->set_content (n.to_string ());
                            break;
                        case "value":
                            iter->set_content (value.to_string ());
                            break;
                        default:
                            break;
                    }
                }
            }
        }
    }


//
//    public override string to_string () {
//        string str_data  = "[%s] : Coefficient\n".printf (id);
//               str_data += "\tn: %d\n\tvalue: %f\n".printf (n, value);
//        return str_data;
//    }
}
