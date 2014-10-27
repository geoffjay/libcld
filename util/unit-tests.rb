#!/usr/bin/env ruby

require 'erb'
require 'optparse'
require 'thor'

#
# Command line interface to manage libcld unit tests.
#
# FIXME: find a way to use config vars
#

module Cld

  #
  # Application class with sub commands.
  #
  class CLI < Thor

    shared_options = [:author, { :type => :string }]

    desc "add OBJECT", "add a unit test file for OBJECT"
    option *shared_options
    def add(object)
      print "Adding unit test for #{object}\n"
      print_options
    end

    desc "add-missing", "add unit tests for all missing classes"
    option *shared_options
    def add_missing()
      print "Adding missing unit tests\n"
      print_options
      print "\n"
      tests = UnitTests.new()
      tests.lib_test_diff(tests.get_objects, tests.get_tests).each do |testclass|
        test = UnitTest.new(testclass, tests.get_template)
        test.save(File.join('../tests/', testclass))
      end
    end

    no_tasks do
      def print_options()
        print "\nOptions:\n"
        print " > author: #{[options[:author]]}\n" if options[:author]
      end
    end
  end

  #
  # Performs the work of finding missing unit tests and provide file names.
  #
  class UnitTests

    def get_objects()
      Dir["../cld/*.vala"]
    end

    def get_tests()
      Dir["../tests/*.vala"]
    end

    def get_template()
      template = File.open('unit-test-template.erb', 'rb')
      content = template.read()
    end

    def is_abstract(file)
      object = file.clone
      object.sub!(/\.vala$/, "")
      object.sub!(/\.\.\/cld\//, "")
      print " > Testing if #{object} is an abstract class\n"
      File.open(file).read() =~ /public abstract class cld\.#{object}/i
    end

    def is_interface(file)
      object = file.clone
      object.sub!(/\.vala$/, "")
      object.sub!(/\.\.\/cld\//, "")
      print " > Testing if #{object} is an interface\n"
      File.open(file).read() =~ /public interface cld\.#{object}/i
    end

    #
    # Get all files from cld that don't have an associated test, aren't an abstract
    # class, and aren't an interface.
    #
    # Example:
    #
    #   lib file  - aichannel.vala
    #   test file - testaichannel.vala
    #
    def lib_test_diff(objects, tests)
      diff = []
      objects.each do |object|
        print "Checking object #{object}\n"
        # XXX: unit tests for interfaces currently exist, should there be?
        #if (!is_abstract(object) && !is_interface(object) && object != "../cld/cld.vala")
        if (!is_abstract(object) && object != "../cld/cld.vala")
          object.sub!(/\.\.\/cld\//, "")
          object = "test#{object}"
          test = object.clone
          test = "../tests/#{test}"
          if (!tests.include? test)
            print " > Adding test #{object}\n"
            diff.push(object)
          else
            print " > Unit test already exists for #{object}\n"
          end
        else
          print " > #{object} is an abstract class\n"
        end
        print "\n"
      end
      return diff
    end
  end

  #
  # Apply the template for the object name provided.
  #
  class UnitTest
    include ERB::Util
    attr_accessor :object, :template, :date

    def initialize(object, template, date=Time.now)
      @object = object
      @template = template
      @date = date
    end

    def render()
      ERB.new(@template).result(binding)
    end

    def save(file)
      print "Adding unit test #{file}\n"
      #File.open(file, "w+") do |f|
        #f.write(render)
      #end
    end
  end

end

Cld::CLI.start(ARGV)
