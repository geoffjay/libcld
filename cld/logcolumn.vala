/**
 * Column class to reference channels to log.
 */
public class Cld.Column : Cld.AbstractObject {

    /**
     * {@inheritDoc}
     */
    public override string id { get; set; }

    /**
     * ID reference of the channel associated with this column.
     */
    public string chref { get; set; }

    /**
     * Referenced channel to use.
     */
    public weak Channel channel { get; set; }

    /**
     * Channel value for tracking.
     */
    public double channel_value { get; set; }

    /**
     * Default constructor.
     */
    public Column () {
        id = "col0";
        chref = "ch0";
    }

    public Column.from_xml_node (Xml.Node *node) {
        if (node->type == Xml.ElementType.ELEMENT_NODE &&
            node->type != Xml.ElementType.COMMENT_NODE) {
            id = node->get_prop ("id");
            chref = node->get_prop ("chref");
        }
    }

    public override string to_string () {
        string str_data  = "[%s] : Column\n".printf (id);
               str_data += "\tchref %s\n\n".printf (chref);
        return str_data;
    }
}
