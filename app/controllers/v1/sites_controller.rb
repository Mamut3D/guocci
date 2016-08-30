module V1
  class SitesController < ApplicationController
    respond_to :json

    def index
      #respond_with(Utils::AppdbReader.all_sites) unless params[:appliance_id]
      respond_with(Utils::AppdbReader.vaproviders_from_appdb) unless params[:appliance_id]

      #sites = Sites.new
      #vaproviders = sites.list
      #vaproviders.blank? ? respond_with(vaproviders, status: 204) : respond_with(vaproviders[0, @limit])
    end

    def show
      sites = Sites.new
      vaprovider = sites.show(params[:id])
      if vaprovider.blank?
        respond_with({ message: "Site with ID #{params[:id]} could not be found!" }, status: 404)
      else
        respond_with(vaprovider)
      end
    end
  end
end
