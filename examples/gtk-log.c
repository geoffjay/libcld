// valac --vapidir=. application-data.vala threads.c -C -H application-data.h --pkg gee-1.0 --pkg cld-0.2 --pkg libxml-2.0 --pkg threads --thread
// sed -i 's/<threads.h>/"threads.h"/' application-data.c
// gcc -o gtk-log gtk-log.c application-data.c threads.c `pkg-config --cflags --libs gtk+-3.0 cld-0.2`

#include <glib.h>
#include <gtk/gtk.h>
#include <cld.h>
#include <glib-object.h>

#include "threads.h"
#include "application-data.h"

#define true 1
#define false 0

gboolean btn_toggled_cb (GtkWidget *widget, gpointer cbdata);

//ApplicationData *data = NULL;

CldXmlConfig* xml = NULL;
CldBuilder* builder = NULL;

gint
main (gint argc, gchar *argv[])
{
    //ApplicationData *data;
    GtkWidget *window;
    GtkWidget *button;
    GtkWidget *box;

    g_type_init ();

    //data = application_data_new_with_xml_file ("cld.xml");
    xml = cld_xml_config_new_with_file_name ("cld.xml");
	builder = cld_builder_new_from_xml_config (xml);

    gtk_init (&argc, &argv);

    window = gtk_window_new (GTK_WINDOW_TOPLEVEL);
    gtk_window_set_default_size (GTK_WINDOW (window), 200, 200);
    g_signal_connect (window, "destroy",
                      G_CALLBACK (gtk_main_quit),
                      NULL);

    box = gtk_box_new (GTK_ORIENTATION_HORIZONTAL, 0);
    gtk_container_add (GTK_CONTAINER(window), box);
    button = gtk_toggle_button_new_with_label ("Log");
    g_signal_connect (button, "toggled",
                      G_CALLBACK (btn_toggled_cb),
                      NULL);
    gtk_box_pack_start (GTK_BOX (box), button, true, true, 5);

    gtk_widget_show_all (window);

    gdk_threads_enter ();
    //application_data_run_acquisition (data);
    gtk_main ();
    //application_data_stop_acquisition (data);
    gdk_threads_leave ();

    g_thread_exit (NULL);

    return false;
}

gboolean
btn_toggled_cb (GtkWidget *widget, gpointer cbdata)
{
    //ApplicationData *app_data = APPLICATION_DATA (data);
    //CldBuilder *builder = CLD_BUILDER (application_data_get_builder (APPLICATION_DATA (app_data)));
    //CldBuilder *builder = CLD_BUILDER (application_data_get_builder (APPLICATION_DATA (data)));
    GeeMap *logs = cld_builder_get_logs (builder);
    GeeMapIterator *it = gee_map_map_iterator (logs);
	CldObject* log = cld_builder_get_object (builder, "log0");

    gee_map_iterator_first (it);
    log = gee_map_iterator_get_value (it);

    if (gtk_toggle_button_get_active (GTK_TOGGLE_BUTTON (widget)))
    {
        g_debug ("start");
        cld_log_file_open (CLD_LOG (log));
        cld_log_run (CLD_LOG (log));
    }
    else
    {
        g_debug ("stop");
        cld_log_stop (CLD_LOG (log));
        cld_log_file_mv_and_date (CLD_LOG (log), false);
    }

    return false;
}
