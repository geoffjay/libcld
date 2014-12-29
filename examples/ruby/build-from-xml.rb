#!/usr/bin/env ruby

require 'gir_ffi'

GirFFI.setup :Cld

config = Cld::XmlConfig.with_file_name('examples/cld.xml')
context = Cld::Context.from_config(config)

context.print_objects(0)

chan = context.get_object('ai0')
print "\nAIChannel ID: #{chan.id}"
