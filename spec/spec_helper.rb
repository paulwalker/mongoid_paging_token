require 'rails'
require 'mongoid_paging_token'
require File.join(File.dirname(__FILE__), 'fake_app')
require 'rspec/rails'
require 'pry'

Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

RSpec.configure do |config|
  config.mock_with :rspec
  config.before :each do
    Mongoid.session(:default).collections.select do |collection|
      collection.name !~ /system/
    end.each(&:drop)
  end
end

Mongoid.load_configuration(
  sessions: { 
    'default' => { 
      'database'  => 'mongoid_paging_token_test', 
      'hosts'     => ['localhost:27017'] } })
