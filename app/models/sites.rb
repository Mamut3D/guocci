class Sites
  def initialize(options = {})
    #
  end

  def list
    vaproviders = Utils::AppdbReader.vaproviders_from_appdb.select do |prov|
      prov['in_production'] == 'true' && !prov['endpoint_url'].blank?
    end
    if vaproviders.blank?
      {}
    else
      vaproviders.collect do |prov|
        {
          id: prov['id'], name: prov['name'],
          country: prov['country']['isocode'],
          endpoint: prov['endpoint_url']
        }
      end
    end
  end

  def show(id)
    vaprovider = Utils::AppdbReader.vaproviders_from_appdb.select { |prov| prov['id'] == id }.first
    if vaprovider.blank?
      {}
    else
      country = vaprovider['country']['isocode'] if vaprovider['country']
      {
        id: vaprovider['id'],
        name: vaprovider['name'],
        country: country,
        endpoint: vaprovider['endpoint_url']
      }
    end
  end
end
