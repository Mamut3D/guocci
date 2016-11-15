class Instances < Base
  def list(site_id)
    appdb_data = read_appdb_data
    endpoint = appdb_data.select { |service| service['id'] == site_id }
    endpoint.first['endpoint'] unless endpoint.blank?
  end

  private

end
