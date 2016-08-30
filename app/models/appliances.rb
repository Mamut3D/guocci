class Appliances
  DB_COLLECTION_APPLIANCES = 'appliances_from_appdb'

  def initialize(options = {})
    @db_collection_appliances = options[:db_collection_appliances] || DB_COLLECTION_APPLIANCES
    @cache = Utils::MongodbCache.new
  end

  def list
    appliances = @cache.cache_read(@db_collection_appliances).flatten
  end

  def show(id)
    appliances = @cache.cache_read(@db_collection_appliances).flatten
    appliance = appliances.select { |appliance| appliance['id'] == id}
    appliance.first if appliance
  end

  def refresh_database
    #TODO put db refresh elsewhere
    @cache.cache_fetch(@db_collection_appliances) {Utils::AppdbReader.all_appliances}
  end
end
