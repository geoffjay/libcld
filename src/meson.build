libcld_header_subdir = 'cld-' + apiversion
libcld_header_dir = join_paths(includedir, libcld_header_subdir)

version_data = configuration_data()
version_data.set('CLD_MAJOR_VERSION', cld_version_major)
version_data.set('CLD_MINOR_VERSION', cld_version_minor)
version_data.set('CLD_MICRO_VERSION', cld_version_micro)
version_data.set('CLD_VERSION', meson.project_version())
version_data.set10('ENABLE_TRACING', get_option('enable_tracing'))

cld_version_h = configure_file(
          input: 'cld-version.h.in',
         output: 'cld-version.h',
    install_dir: libcld_header_dir,
        install: true,
  configuration: version_data)

cld_debug_h = configure_file(
          input: 'cld-debug.h.in',
         output: 'cld-debug.h',
    install_dir: libcld_header_dir,
        install: true,
  configuration: version_data)

libcld_generated_headers = [
  cld_debug_h,
  cld_version_h,
]

libcld_deps = [
  libgio_dep,
  libgee_dep,
  libxml_dep,
  libjson_glib_dep,
  libgsl_dep,
  libsqlite_dep,
  libcomedi_dep,
  libmodbus_dep,
  linux_dep,
  posix_dep,
  cc.find_library('m', required: false),
]

libcld_sources = [
  libcld_generated_headers,
  'cld.vala',
  'cld-abstractchannel.vala',
  'cld-abstractcontainer.vala',
  'cld-abstractcontroller.vala',
  'cld-abstractdevice.vala',
  'cld-abstractfilter.vala',
  'cld-abstractlog.vala',
  'cld-abstractmodule.vala',
  'cld-abstractobject.vala',
  'cld-abstractport.vala',
  'cld-abstractsensor.vala',
  'cld-abstracttask.vala',
  'cld-acquisitioncontroller.vala',
  'cld-actuator.vala',
  'cld-aichannel.vala',
  'cld-aochannel.vala',
  'cld-automationcontroller.vala',
  'cld-brabendermodule.vala',
  'cld-buildable.vala',
  'cld-builder.vala',
  'cld-calibration.vala',
  'cld-channel.vala',
  'cld-circularbuffer.vala',
  'cld-coefficient.vala',
  'cld-comedidevice.vala',
  'cld-comeditask.vala',
  'cld-connector.vala',
  'cld-container.vala',
  'cld-context.vala',
  'cld-controller.vala',
  'cld-control.vala',
  'cld-csvlog.vala',
  'cld-daq.vala',
  'cld-dataseries.vala',
  'cld-device.vala',
  'cld-dichannel.vala',
  'cld-dochannel.vala',
  'cld-entry.vala',
  'cld-filter.vala',
  'cld-flowsensor.vala',
  'cld-heidolphmodule.vala',
  'cld-licormodule.vala',
  'cld-logcolumn.vala',
  'cld-logcontroller.vala',
  'cld-log.vala',
  'cld-modbusport.vala',
  'cld-module.vala',
  'cld-multiplexer.vala',
  'cld-object.vala',
  'cld-parkermodule.vala',
  'cld-pid.vala',
  'cld-port.vala',
  'cld-pressuresensor.vala',
  'cld-rawchannel.vala',
  'cld-rootcontainer.vala',
  'cld-runnable.vala',
  'cld-sensor.vala',
  'cld-serialport.vala',
  'cld-socketport.vala',
  'cld-sqlitelog.vala',
  'cld-system.vala',
  'cld-task.vala',
  'cld-temperaturesensor.vala',
  'cld-vchannel.vala',
  'cld-velmexmodule.vala',
  'cld-xmlconfig.vala',
]

if get_option('enable_matheval')
  libcld_deps += libmatheval_dep
  libcld_sources += [
    'cld-mathchannel.vala',
  ]
endif

if libdir == '' or includedir == ''
  error('You must set pkglibdir and pkgincludedir when using as a subproject')
endif

libcld = library('cld-' + apiversion, libcld_sources,
  link_depends: 'cld.map',
     link_args: [ '-Wl,--version-script,' + join_paths(meson.current_source_dir(), 'cld.map'), '-lcomedi' ],
   vala_header: 'cld.h',
     vala_vapi: 'cld-@0@.vapi'.format(apiversion),
      vala_gir: 'Cld-@0@.gir'.format(apiversion),
  dependencies: libcld_deps,
     soversion: soversion,
       version: libversion,
       install: true,
   install_dir: [ true, true, true, true ],
)

g_ir_compiler = find_program('g-ir-compiler', required: false)
if g_ir_compiler.found()
  custom_target('Cld typelib',
        command: [ g_ir_compiler, '--shared-library', libcld.full_path(), '--output', '@OUTPUT@', join_paths(meson.current_build_dir(), 'Cld-@0@.gir'.format(apiversion)) ],
          #input: join_paths(meson.current_build_dir(), 'Cld-@0@.gir'.format(apiversion)),
         output: 'Cld-@0@.typelib'.format(apiversion),
        depends: libcld,
        install: true,
    install_dir: join_paths(get_option('libdir'), 'girepository-1.0')
)
endif

libcld_dep = declare_dependency(
              sources: libcld_generated_headers,
         dependencies: libcld_deps,
            link_with: libcld,
  include_directories: include_directories('.'),
)

pkgg = import('pkgconfig')

pkgg.generate(
    libraries: [libcld],
      subdirs: join_paths(package_subdir, libcld_header_subdir),
      version: meson.project_version(),
         name: 'cld',
     filebase: 'cld-@0@'.format(apiversion),
  description: 'A DAQ object library for GLib',
     requires: 'gio-2.0',
  install_dir: join_paths(libdir, 'pkgconfig'),
)
