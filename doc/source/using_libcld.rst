============
Using libcld
============

The content provided here is a work in progress and at present won't work
correctly with the ``master`` branch of libcld, they should however be fine
when using ``develop``.

Vala libraries can be set to generate GObject Introspection (GIR) files that
enable them to be used in a variety of languages. Some examples will be provided
using JavaScript, Lua, Perl, Python, Ruby, and of course Vala. All of these
examples are available in the repository hosted on GitHub.

Examples
========

This basic XML configuration will be used for all examples:

.. code-block:: xml

    <?xml version="1.0" encoding="ISO-8859-1"?>
    <cld xmlns:cld="urn:libcld">
        <cld:objects>
            <!-- this relies on hardware to be present, it shouldn't matter though -->
            <cld:object id="daqctl0" type="controller" ctype="acquisition">
                <cld:object id="dev0" type="device" driver="comedi">
                    <cld:property name="hardware">PCI-1713</cld:property>
                    <cld:property name="type">input</cld:property>
                    <cld:property name="file">/dev/comedi0</cld:property>
                    <cld:object id="tk0" type="task" ttype="comedi">
                        <cld:property name="exec-type">polling</cld:property>
                        <cld:property name="subdevice">0</cld:property>
                        <cld:property name="direction">read</cld:property>
                        <cld:property name="interval-ms">100</cld:property>
                        <cld:object id="tkch0" type="channel" chref="ai0"/>
                    </cld:object>
                </cld:object>
            </cld:object>

            <cld:object id="logctl0" type="controller" ctype="log">
                <cld:object id="log0" type="log" ltype="csv">
                    <cld:property name="title">Data Log</cld:property>
                    <cld:property name="path">./</cld:property>
                    <cld:property name="file">log.dat</cld:property>
                    <cld:property name="format">%F-%T</cld:property>
                    <cld:property name="rate">10.000</cld:property>
                    <cld:object id="col0" type="column" chref="ai0"/>
                </cld:object>
            </cld:object>

            <cld:object id="cal0" type="calibration">
                <cld:property name="units">Volts</cld:property>
                <cld:object id="cft0" type="coefficient">
                    <cld:property name="n">0</cld:property>
                    <cld:property name="value">0.000</cld:property>
                </cld:object>
                <cld:object id="cft1" type="coefficient">
                    <cld:property name="n">1</cld:property>
                    <cld:property name="value">1.000</cld:property>
                </cld:object>
            </cld:object>

            <cld:object id="ai0" type="channel" ref="/daqctl0/dev0" ctype="analog" direction="input">
                <cld:property name="tag">IN0</cld:property>
                <cld:property name="desc">Sample Input</cld:property>
                <cld:property name="num">0</cld:property>
                <cld:property name="calref">/cal0</cld:property>
                <cld:property name="taskref">/daqctl0/dev0/tk0</cld:property>
            </cld:object>
            <cld:object id="ao0" type="channel" ref="/daqctl0/dev0" ctype="analog" direction="output">
                <cld:property name="tag">OUT0</cld:property>
                <cld:property name="desc">Output1</cld:property>
                <cld:property name="num">0</cld:property>
                <cld:property name="calref">/cal0</cld:property>
                <cld:property name="taskref">/daqctl0/dev0/tk1</cld:property>
            </cld:object>

            <cld:object id="autoctl0" type="controller" ctype="automation">
                <cld:object id="ctl0" type="control">
                    <cld:object id="pid0" type="pid-2">
                        <cld:property name="desc">PID0</cld:property>
                        <cld:property name="dt">10</cld:property>
                        <cld:property name="sp">0.000000</cld:property>
                        <cld:property name="kp">0.000000</cld:property>
                        <cld:property name="ki">0.020000</cld:property>
                        <cld:property name="kd">0.000000</cld:property>
                        <cld:object id="pv0" type="process_value" chref="ai0"/>
                        <cld:object id="pv1" type="process_value" chref="ao0"/>
                    </cld:object>
                </cld:object>
            </cld:object>
        </cld:objects>
    </cld>

Vala
----

.. code-block:: vala
   :linenos:

JavaScript
----------

.. code-block:: javascript
   :linenos:

   const Cld = imports.gi.Cld;

   function main() {
       let config = Cld.XmlConfig.with_file_name("examples/cld.xml");
       let context = Cld.Context.from_config(config);

       context.print_objects(0);

       let chan = context.get_object("ai0");

       chan.connect('new-value',
           function(o, event) {
               print(chan.id, "value:", chan.raw_value);
           });

       chan.add_raw_value (0.1);
       chan.add_raw_value (0.2);
       chan.add_raw_value (0.3);

       print(chan.id, "current value:", chan.current_value);
   }

   main();

Lua
---

.. code-block:: lua
   :linenos:

   -- sudo yum install lua-devel luarocks
   -- sudo luarocks install lgi
   -- sudo ln -s /usr/lib/lua/5.2/lgi/ /usr/lib64/lua/5.2/lgi

   local lgi = require('lgi')
   local Cld = lgi.require('Cld', '0.2')

   local config = Cld.XmlConfig.with_file_name('examples/cld.xml')
   local context = Cld.Context.from_config(config)

   Cld.Context.print_objects(context, 0)

   local chan = Cld.Context.get_object(context, 'ai0')
   print("\nAIChannel ID: " .. chan.id)

Perl
----

.. code-block:: perl
   :linenos:

   #!/usr/bin/perl

   use strict;
   use warnings;

   use Glib::Object::Introspection;

   Glib::Object::Introspection->setup(
       basename => 'Cld',
       version  => '0.2',
       package  => 'Cld'
   );

   my $config = Cld::XmlConfig->with_file_name("examples/cld.xml");
   my $context = Cld::Context->from_config($config);

   $context->print_objects(0);

   my $chan = $context->get_object("ai0");
   print "AIChannel ID: " . $chan->get_property("id");

Python
------

.. code-block:: python
   :linenos:

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

Ruby
----

.. literalinclude:: examples/ruby/build-from-xml.rb
   :language: ruby
   :linenos:

   require 'gir_ffi'

   GirFFI.setup :Cld

   config = Cld::XmlConfig.with_file_name('examples/cld.xml')
   context = Cld::Context.from_config(config)

   context.print_objects(0)

   chan = context.get_object('ai0')
   print "\nAIChannel ID: #{chan.id}"
