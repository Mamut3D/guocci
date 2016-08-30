class Sites
  DB_COLLECTION_SITES = 'sites_from_appdb'

  def initialize(options = {})
    @db_collection_sites = options[:db_collection_sites] || DB_COLLECTION_SITES
    @cache = Utils::MongodbCache.new
  end

  def list
    @cache.cache_read(@db_collection_sites).flatten
  end

  def show(id)
    vaprovider = @cache.cache_read(@db_collection_sites).select { |prov| prov['id'] == id }.first
  end

  def refresh_database
    #TODO put db refresh elsewhere
    @cache.cache_fetch(@db_collection_sites) {Utils::AppdbReader.all_sites}
  end

end
