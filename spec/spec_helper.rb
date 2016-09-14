require 'simplecov'
require 'vcr'

SimpleCov.start 'rails' do
  add_filter '/vendor'
end

ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)

require 'rails/all'
require 'rspec/rails'

RSpec.configure do |config|
  config.color = true
  config.tty = true
  config.order = 'random'
end

VCR.configure do |c|
  c.cassette_library_dir = 'spec/vcr'
  c.hook_into :webmock
  # c.debug_logger = File.open( '/tmp/vcrlog', 'w')
end
