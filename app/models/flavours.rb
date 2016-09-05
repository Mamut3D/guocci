class Flavours < Base
  def list(appliance_id, service_id)
    message = app_and_serv_check(appliance_id, service_id)
    message.blank? ? get_flavours(service_id) : message
  end

  def show(appliance_id, service_id, flavour_id)
    flavours = list(appliance_id, service_id)
    return flavours if flavours.first.key? ('message')
    flavours.select! { |flavour| flavour['id'] == flavour_id }
    if flavours.blank?
      [{ message: "Flavour '#{flavour_id}' at site '#{service_id}' for appl. '#{appliance_id}' could not be found!" }]
    else
      flavours
    end
  end

  private

  def get_flavours(service_id)
    servs_and_flavs = get_servs_and_flavs
    servs_and_flavs.collect do |service|
      if service['id'] == service_id
        service['flavours']
      end
    end.compact.flatten
  end


end
