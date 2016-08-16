module V1
  class SitesController < ApplicationController
    respond_to :json

    def index
      vaproviders = vaproviders_from_appdb.select { |prov| prov['in_production'] == 'true' && !prov['endpoint_url'].blank? }

      if vaproviders.blank?
        respond_with(status: 204)
      else
        # vaproviders.reject! { |prov| vaprovider_appliances(prov).blank? }
        providers = vaproviders.collect do |prov|
          {
            id: prov['id'], name: prov['name'],
            country: prov['country']['isocode'],
            endpoint: prov['endpoint_url']
          }
        end

        respond_with(providers[0, @limit])
      end
    end

    def show
      vaprovider = vaproviders_from_appdb.select { |prov| prov['id'] == params[:id] }.first
      if vaprovider
        site_data = {}
        site_data[:id] = vaprovider['id']
        site_data[:name] = vaprovider['name']
        site_data[:country] = vaprovider['country']['isocode'] if vaprovider['country']
        site_data[:endpoint] = vaprovider['endpoint_url']
        # site_data[:sizes] = vaprovider_sizes(vaprovider)
        # site_data[:appliances] = vaprovider_appliances(vaprovider)
        respond_with(site_data)
      else
        response = {
          code: 42,
          message: "Site with ID #{params[:id]} could not be found!"
        }
        respond_with(response, status: 404)
      end
    end
  end
end
