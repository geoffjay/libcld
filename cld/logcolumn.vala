/**
 * Column class to reference channels to log.
 */
public class Cld.Column : Cld.AbstractContainer {

    /**
     * Property backing fields.
     */
    protected weak Cld.Channel _channel;

    /**
     * ID reference of the channel associated with this column.
     */
    public string chref { get; set; }

    /**
     * Referenced channel to use.
     */
    public Cld.Channel channel {
        get {
            if (_channel == null) {
                var channels = get_children (typeof (Cld.Channel));
                foreach (var chan in channels.values) {
                    _channel = chan as Cld.Channel;
                    break;
                }
            }

            return _channel;
        }
        set { _channel = value; }
    }

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
}
