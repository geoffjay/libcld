test_deps = [
  libcld_dep,
  libgio_dep,
  libgee_dep,
]

legacy_test_sources = [
  'tests.vala',
  'test-aichannel.vala',
  'test-aochannel.vala',
  'test-buildable.vala',
  'test-builder.vala',
  'test-calibration.vala',
  'test-case.vala',
  'test-channel.vala',
  'test-coefficient.vala',
  'test-container.vala',
  'test-control.vala',
  'test-csv-log.vala',
  'test-device.vala',
  'test-dichannel.vala',
  'test-dochannel.vala',
  'test-dummy-container.vala',
  'test-dummy-object.vala',
  'test-filter.vala',
  'test-flow-sensor.vala',
  'test-object.vala',
  'test-pid.vala',
  'test-port.vala',
  'test-sensor.vala',
  'test-serial-port.vala',
  'test-socket-port.vala',
  'test-vchannel.vala',
  'test-xml-config.vala',
]

test('legacy', executable('legacy-test', legacy_test_sources,
                          dependencies: test_deps))

# TODO figure out why this causes CI to fail
#python = find_program('python3')
#if g_ir_compiler.found()
    #test('gi', python,
         #args: meson.current_source_dir() + '/gi-test.py' ,
         #env: ['GI_TYPELIB_PATH=' + join_paths(meson.current_build_dir(), '../src')])
#endif

# TODO move to a new multi-exec test framework
#cld_tests = [
  #'build',
  #'configure',
  #'control',
  #'context',
#]

#foreach name : cld_tests
  #test(name, executable('test-' + name, 'test-' + name + '.vala',
                        #dependencies: test_deps),
       #env: ['G_TEST_SRCDIR=' + meson.current_source_dir()])
#endforeach
