class Appliances
  def initialize(options = {})
    #
  end

  def list(site_id)
    vaprovider = Utils::AppdbReader.vaproviders_from_appdb.select { |prov| prov['id'] == site_id }.first
    if vaprovider
      appliances = Utils::AppdbReader.vaprovider_appliances(vaprovider)
      appliances.blank? ? {} : appliances
    end
  end

  def show(id)
    vaprovider = Utils::AppdbReader.vaproviders_from_appdb.select { |prov| prov['id'] == site_id }.first
    if vaprovider
      appliances = Utils::AppdbReader.vaprovider_appliances(vaprovider)
      appliance = appliances.select { |appl| appl['id'] == id }
      { message: "Appliance with ID #{id} could not be found at site #{site_id}!" } unless appliance
    else
      { message: "Site with ID #{site_id} could not be found!" }
    end
  end
end
