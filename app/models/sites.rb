class Sites < Base
  def list(appliance_id)
    appdb_data = read_appdb_data
    if appliance_id.blank?
      select_services(appdb_data)
    else
      app_services = select_app_servs(appliance_id, appdb_data)
      raise Errors::ApplianceNotFoundError, "Appliance with ID '#{appliance_id}' " \
            "could not be found!" if app_services.blank?
      app_services
    end
  end

  def show(appliance_id, service_id)
    appdb_data = read_appdb_data
    app_and_serv_check(appliance_id, service_id, appdb_data)
    select_app_servs(appliance_id, appdb_data).select { |service| service[:id] == service_id }.first
  end

  private

  def select_app_servs(appliance_id, appdb_data)
    service_ids = get_service_ids(appliance_id, appdb_data)
    select_services(appdb_data).select! do |service|
      service[:id].in? service_ids
    end
  end

  def select_services(appdb_data)
    appdb_data.collect do |service|
      {
        id: service['id'],
        name: service['name'],
        country: service['country'],
        endpoint: service['endpoint']
      }
    end
  end
end
