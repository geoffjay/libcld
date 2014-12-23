#!/usr/bin/env coffee

gir = require 'gir'
cld = gir.load 'Cld', '0.2'

config = new Cld.XmlConfig.with_file_name
    file_name: 'examples/cld.xml'

context = new Cld.Context.from_config
    config: config

context.print_objects 0

chan = context.get_object 'ai0'
process.stdout.write '#{chan.id}'
