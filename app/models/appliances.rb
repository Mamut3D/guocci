class Appliances
  DB_COLLECTION_VAPROVIDERS = 'vaproviders_from_appdb'
  DB_COLLECTION_APPLIANCES = 'appliances_from_appdb'

  def initialize(options = {})
    @db_collection_vaproviders = options[:db_collection_vaproviders] || DB_COLLECTION_VAPROVIDERS
    @db_collection_appliances = options[:db_collection_appliances] || DB_COLLECTION_APPLIANCES
    @cache = Utils::MongodbCache.new
  end

  def list
    appliances = @cache.cache_read(@db_collection_appliances).flatten
  end

  def show(id)
    appliances = @cache.cache_read(@db_collection_appliances).flatten
    #TODO
    #appliances.collect { |appliance| appliance['id']}
  end

  def refresh_database
    @cache.cache_fetch(@db_collection_appliances) {Utils::AppdbReader.all_appliances}
    #TODO
    #@cache.cache_fetch(@db_collection_vaproviders) {Utils::AppdbReader.}
  end
end
