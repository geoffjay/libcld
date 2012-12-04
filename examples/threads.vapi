[CCode (cprefix = "Threads", lower_case_cprefix = "threads_", cheader_filename = "threads.h")]
namespace Threads {
    [Compact]
    [CCode (cname = "threads_acq_func")]
    public void * acq_func (GLib.Object? data = null);
}
