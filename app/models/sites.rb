class Sites < Base
  def list(appliance_id)
    appliance_id.blank? ? get_services : get_app_sites(appliance_id)
  end

  def show(appliance_id,id)
    get_app_sites(appliance_id).select { |service| service[:id] == id }.first
  end

  private

  def get_services
    format_sites(get_servs_and_flavs)
  end

  def get_app_sites(appliance_id)
    service_ids = get_service_ids(appliance_id)
    get_services.select! do |service|
      service[:service_id].in? service_ids
    end
  end

  def format_sites(sites_and_flavours)
    sites_and_flavours.collect do |site|
      {
        id: site['siteid'],
        name: site['name'],
        country: site['country'],
        service_id: site['service_id']
      }
    end
  end
end
