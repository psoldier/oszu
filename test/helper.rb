# encoding: utf-8
# helper.rb
ENV['RACK_ENV'] = 'test'

require 'minitest/autorun'
require 'rack/test'
require 'mocha/mini_test'
#require 'capybara/poltergeist'

require File.expand_path '../../app.rb', __FILE__

include Rack::Test::Methods
include Mocha::API

Mongoid.purge!

require_relative 'spawners'

def app
  Cuba
end

#
# Patch to stub callbacks on models, or any "complicate" class
#
class Object
  def stub_any_instance(method, result)
    self.class_eval do
      alias_method :"stubbed_#{method}", method

      send(:define_method, method) do |*args|
        result.respond_to?(:call) ? result.(*args) : result
      end
    end

    yield
  ensure
    self.class_eval do
      undef_method method
      alias_method method, :"stubbed_#{method}"
      undef_method :"stubbed_#{method}"
    end
  end
end
