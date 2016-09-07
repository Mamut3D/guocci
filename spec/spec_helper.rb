require 'simplecov'
require 'rspec/rails'
require 'rspec/autorun'

SimpleCov.start do
  add_filter '/vendor'
end

RSpec.configure do |config|
  config.color = true
  config.tty = true
  config.order = 'random'
end
