class Base

    def initialize(options = {})
      @db_collection = options[:db_collection] || DB_COLLECTION
      @cache = options[:cache] || Utils::MongodbCache.new
      #TODO change refresh_database mechanic
      refresh_database
    end

    protected
    DB_COLLECTION = 'appdb'

    def read_appdb_data
      @cache.cache_read(@db_collection).flatten
    end

    def refresh_database
      @cache.cache_fetch(@db_collection) {Utils::AppdbReader.all}
    end

    def get_service_ids(appliance_id, appdb_data)
      appdb_data = read_appdb_data
      appdb_data.select! do |site|
        !site['appliance'].select! { |appliance| appliance['id'] == appliance_id}.blank?
      end
      appdb_data.collect { |service| service['id'] }
    end

    def app_and_serv_check(appliance_id, service_id, appdb_data)
      service_ids = get_service_ids(appliance_id, appdb_data)
      raise Errors::ApplianceNotFoundError, "Appliance with ID '#{appliance_id}' " \
            "could not be found!" if service_ids.blank?
      service_ids.select! { |id| id == service_id }
      raise Errors::SiteNotFoundError, "Appliance '#{appliance_id}' is not " \
            "provided at site with ID '#{service_id}'!" if service_ids.blank?
    end
end
