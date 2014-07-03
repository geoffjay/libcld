#!/usr/bin/env python
#! -*- coding: utf-8 -*-

from gi.repository import Cld

if __name__ == '__main__':
    # Create context from XML
    config = Cld.XmlConfig.with_file_name("examples/cld.xml")
    context = Cld.Context.from_config(config)
    print "\n"
    context.print_objects(0)
    print "\n"
    chan = context.get_object("ai0")
    print chan.get_property("id")
