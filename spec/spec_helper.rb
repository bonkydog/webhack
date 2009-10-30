# This file is copied to ~/spec when you run 'ruby script/generate rspec'
# from the project root directory.
ENV["RAILS_ENV"] ||= 'test'
require File.dirname(__FILE__) + "/../config/environment" unless defined?(RAILS_ROOT)
require 'spec/autorun'
require 'spec/rails'

require 'mocha'
require 'shoulda'

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}


Spec::Runner.configure do |config|
  # If you're not using ActiveRecord you should remove these
  # lines, delete config/database.yml and disable :active_record
  # in your config/boot.rb
  config.use_transactional_fixtures = true
  config.use_instantiated_fixtures  = false
  config.fixture_path = RAILS_ROOT + '/spec/fixtures/'

  # == Fixtures
  #
  # You can declare fixtures for each example_group like this:
  #   describe "...." do
  #     fixtures :table_a, :table_b
  #
  # Alternatively, if you prefer to declare them only once, you can
  # do so right here. Just uncomment the next line and replace the fixture
  # names with your fixtures.
  #
  # config.global_fixtures = :table_a, :table_b
  #
  # If you declare global fixtures, be aware that they will be declared
  # for all of your examples, even those that don't use them.
  #
  # You can also declare which fixtures to use (for example fixtures for test/fixtures):
  #
  # config.fixture_path = RAILS_ROOT + '/spec/fixtures/'
  #
  # == Mock Framework
  #
  # RSpec uses it's own mocking framework by default. If you prefer to
  # use mocha, flexmock or RR, uncomment the appropriate line:
  #
  config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr
  #
  # == Notes
  #
  # For more information take a look at Spec::Runner::Configuration and Spec::Runner
end


shared_examples_for "a restfully routed resource" do

  describe "resource routes" do

    before do
      @name = described_class.name.sub(/Controller$/, '').underscore
      @resource_symbol = @name.to_sym
    end

    it "should route to restful index" do
      should route(:get, "/#{@name}").to(:controller => @resource_symbol, :action => :index)
    end

    it "should route to restful show" do
      should route(:get, "/#{@name}/1").to(:controller => @resource_symbol, :action => :show, :id => 1)
    end

    it "should route to restful edit" do
      should route(:get, "/#{@name}/1/edit").to(:controller => @resource_symbol, :action => :edit, :id => 1)
    end

    it "should route to restful create" do
      should route(:post, "/#{@name}").to(:controller => @resource_symbol, :action => :create)
    end

    it "should route to restful update" do
      should route(:put, "/#{@name}/1").to(:controller => @resource_symbol, :action => :update, :id => 1)
    end

    it "should route to restful destroy" do
      should route(:delete, "/#{@name}/1").to(:controller => @resource_symbol, :action => :destroy, :id=> 1)
    end
  end
end

shared_examples_for "a timestamped model" do
  describe "timestamp fields" do
    it "should have a created_at field" do
      should have_db_column(:created_at).of_type(:datetime).with_options(:null => false)
    end

    it "should have an updated_at field" do
      should have_db_column(:updated_at).of_type(:datetime).with_options(:null => false)
    end
  end
end