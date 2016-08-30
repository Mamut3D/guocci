require 'json'
require 'mongo'

module Utils
  # Please burn in hell dear rubocop
  # Best Regards
  # Your Mama
  # (fat)
  class MongodbCache
    attr_reader :logger

    MONGODB_HOST = '127.0.0.1'.freeze
    MONGODB_NAME = 'cachedb'.freeze
    MONGODB_PORT = '27017'.freeze

    def initialize(options = {})
      @logger = options[:logger] || Logger.new(STDOUT)
      @mongodb_host = options[:mongodb_host] || MONGODB_HOST
      @mongodb_name = options[:mongodb_name] || MONGODB_NAME
      @mongodb_port = options[:mongodb_port] || MONGODB_PORT
      @client = Mongo::Client.new([@mongodb_host + ':' + @mongodb_port], database: @mongodb_name)
    end

    def cache_fetch(key, expiration = 1.hour)
      raise 'You have to provide a block!' unless block_given?

      cached_data = @client[:cache].find(key: key).first

      cache_valid?(cached_data, expiration) ? cache_hit(cached_data, key) : cache_miss(yield, key)
    end

    def cache_read(key)
      cached_data = @client[:cache].find(key: key).first[:data]
      JSON.parse cached_data
    end

    private

    def cache_hit(cached_data, key)
      logger.debug "Cache hit on #{key.inspect}"
      JSON.parse cached_data[:data]
    end

    def cache_miss(data, key)
      logger.debug "Cache miss on #{key.inspect}"

      @client[:cache].delete_one(key: key)
      json_data = JSON.pretty_generate(data)

      data_to_cache = {
        key: key,
        time_of_creation: Time.now,
        data: json_data
      }
      @client[:cache].insert_one(data_to_cache)
      data
    end

    def cache_valid?(cached_data, expiration)
      !cached_data.blank? && (Time.now - expiration) < cached_data[:time_of_creation]
    end
  end
end
