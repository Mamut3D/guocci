class Appliances < Base
  def list
    read_appdb_data.collect do |service|
      service['appliance']
    end.flatten
  end

  def show(id)
    appliance = list.select { |appliance| appliance['id'] == id}
    raise Errors::ApplianceNotFoundError, "Appliance with ID '#{id}' " \
          "could not be found!" if appliance.blank?
    appliance.first
  end
end
