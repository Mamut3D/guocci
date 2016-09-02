class Flavours < Base
  def list(appliance_id,site_id_)
    sites_and_flavours = get_servs_and_flavs
    #get_appliance(appliance_id)
    #get_flavours(sites_and_flavours)
  end

  def show(id)
    sites_and_flavours = @cache.cache_read(@db_coll_sites_and_flavour).flatten
    flavours = get_flavours(sites_and_flavours)
    flavours.select { |prov| prov['id'] == id }.first
  end

  private

  def get_flavours(sites_and_flavours)


  end

  def get_appliance(appliance_id)
    appliances = @cache.cache_read(@db_collection_appliances).flatten
    appliance = appliances.select { |appliance| appliance['id'] == appliance_id}
    appliance.first if appliance
  end

end
