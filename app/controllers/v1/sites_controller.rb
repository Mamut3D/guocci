module V1
  class SitesController < ApplicationController
    respond_to :json

    def index
      sites = Sites.new
      sites_list = sites.list(params[:appliance_id])
      if params[:appliance_id].blank?
        sites_list.blank? ? respond_with(nil, status: 204) : respond_with(sites_list[0, @limit])
      else
        respond_with(sites_list[0, @limit])
      end
    end

    def show
      sites = Sites.new
      respond_with(sites.show(params[:appliance_id],params[:id]))
    end
  end
end
