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
