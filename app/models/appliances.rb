class Appliances < Base
  def list
    get_servs_and_apps.collect do |service|
      service['appliance']
    end.flatten
  end

  def show(id)
    appliance = list.select { |appliance| appliance['id'] == id}
    appliance.first if appliance
  end
end
