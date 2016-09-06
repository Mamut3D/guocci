class Flavours < Base
  def list(appliance_id, service_id)
    appdb_data = read_appdb_data
    app_and_serv_check(appliance_id, service_id, appdb_data)
    appdb_data.collect do |service|
      if service['id'] == service_id
        service['flavours']
      end
    end.compact.flatten
  end

  def show(appliance_id, service_id, flavour_id)
    flavours = list(appliance_id, service_id)
    flavours.select! { |flavour| flavour['id'] == flavour_id }
    raise Errors::FlavourNotFoundError, "Flavour '#{flavour_id}' at site '#{service_id}' " \
          "for appl. '#{appliance_id}' could not be found!" if flavours.blank?
    flavours.first
  end
end
