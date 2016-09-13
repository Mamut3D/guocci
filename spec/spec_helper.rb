require 'simplecov'
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
