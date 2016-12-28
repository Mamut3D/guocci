class Base
  def initialize(options = {})
    @db_collection = options[:db_collection] || DB_COLLECTION
    @cache = options[:cache] || Utils::MongodbCache.new
    # TODO: change refresh_database mechanic
    refresh_database
  end

  protected

  DB_COLLECTION = 'appdb'.freeze
  CA_PATH = '/etc/grid-security/certificates'

  def read_appdb_data
    @cache.cache_read(@db_collection).flatten
  end

  def refresh_database
    @cache.cache_fetch(@db_collection) { Utils::AppdbReader.all }
  end

  def service_ids(appliance_id, appdb_data)
    appdb_data.collect do |service|
      service['id'] if service['appliances'].any? { |appliance| appliance['id'] == appliance_id }
    end.compact
  end

  def app_and_serv_check(appliance_id, service_id, appdb_data)
    service_ids = service_ids(appliance_id, appdb_data)
    raise Errors::NotFoundError, "Appliance with ID '#{appliance_id}' could not be found!" if service_ids.blank?
    service_ids.select! { |id| id == service_id }

    raise Errors::NotFoundError, "Appliance ''#{appliance_id}'' is not provided at site with ID '#{service_id}'!" if service_ids.blank?
  end

  def occi_client(endpoint, cert)
    #TODO rework client to enable caching
    @client ||= Occi::Api::Client::ClientHttp.new({
      :endpoint => endpoint,
      :auth => {
        :voms               => true,
        :type               => "x509",
        :user_cert          => cert,
        :user_cert_password => "",
        :ca_path            => CA_PATH
      },
      :log => {
        :level  => Rails.env.production? ? Occi::Api::Log::ERROR : Occi::Api::Log::DEBUG,
        :logger => Rails.logger,
        :out => Rails.logger,
      }
    })
  end

  def endpoint(site_id)
    appdb_data = read_appdb_data
    ep = appdb_data.select { |service| service['id'] == site_id }
    ep.first['endpoint'] unless ep.blank?
  end

end
