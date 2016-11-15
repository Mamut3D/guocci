class Appliances < Base
  def list
    read_appdb_data.compact.collect do |service|
      service['appliances']
    end.flatten.compact
  end

  def show(id)
    appliance = list.select { |appl| appl['id'] == id }
    raise Errors::NotFoundError, "Appliance with ID '#{id}' could not be found!" if appliance.blank?
    appliance.first
  end
end
