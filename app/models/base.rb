class Base

    def initialize(options = {})
      @db_coll_sites_and_flavour = options[:db_coll_sites_and_flavour] || DB_COL_SITES_AND_FLAVOURS
      @db_collection_appliances = options[:db_collection_appliances] || DB_COLLECTION_APPLIANCES
      #TODO get cache from controllers
      @cache = Utils::MongodbCache.new
      #TODO change refresh_database mechanic
      refresh_database
    end

    protected
    DB_COL_SITES_AND_FLAVOURS = 'sites_from_appdb'
    DB_COLLECTION_APPLIANCES = 'appliances_from_appdb'

    def get_servs_and_flavs
      @cache.cache_read(@db_coll_sites_and_flavour).flatten
    end

    def get_servs_and_apps
      @cache.cache_read(@db_collection_appliances).flatten
    end

    def refresh_database
      @cache.cache_fetch(@db_collection_appliances) {Utils::AppdbReader.appliances}
      @cache.cache_fetch(@db_coll_sites_and_flavour) {Utils::AppdbReader.sites_and_flavours}
    end

    def get_service_ids(appliance_id)
      sites_and_apps = get_servs_and_apps
      sites_and_apps.select! do |site|
        !site['appliance'].select! { |appliance| appliance['id'] == appliance_id}.blank?
      end
      sites_and_apps.collect { |service| service['id'] }
    end


    def app_and_serv_check(appliance_id, service_id)
      service_ids = get_service_ids(appliance_id)
      raise Errors::ApplianceNotFoundError, "Appliance with ID '#{appliance_id}' " \
            "could not be found!" if service_ids.blank?
      service_ids.select! { |id| id == service_id }
      raise Errors::SiteNotFoundError, "Appliance '#{appliance_id}' is not " \
            "provided at site with ID '#{service_id}'!" if service_ids.blank?
    end
end
