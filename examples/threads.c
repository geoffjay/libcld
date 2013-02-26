#include <glib.h>

#include "threads.h"
#include "application-data.h"

void
threads_acq_func (GObject *data)
{
    ApplicationData *app_data = (ApplicationData *)data;

    while (application_data_get_acq_active (APPLICATION_DATA (app_data)))
    {
        /* thread execution section goes here */
        g_debug ("Test acquisition thread.");
        usleep (1000000);
    }
}
