class Sites < Base
  def list(appliance_id)
    if appliance_id.blank?
      get_services
    else
      app_services = get_app_servs(appliance_id)
      raise Errors::ApplianceNotFoundError, "Appliance with ID '#{appliance_id}' " \
            "could not be found!" if app_services.blank?
      app_services
    end
  end

  def show(appliance_id, service_id)
    app_and_serv_check(appliance_id, service_id)
    get_app_servs(appliance_id).select { |service| service[:id] == service_id }
  end

  private

  def get_services
    format_sites(get_servs_and_flavs)
  end

  def get_app_servs(appliance_id)
    service_ids = get_service_ids(appliance_id)
    get_services.select! do |service|
      service[:id].in? service_ids
    end
  end

  def format_sites(servs_and_flavours)
    servs_and_flavours.collect do |service|
      {
        id: service['id'],
        name: service['name'],
        country: service['country'],
        endpoint: service['endpoint']
      }
    end
  end
end
