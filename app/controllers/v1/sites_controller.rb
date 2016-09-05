module V1
  class SitesController < ApplicationController
    respond_to :json

    def index
      sites = Sites.new
      sites_list = sites.list(params[:appliance_id])
      if params[:appliance_id].blank?
        sites_list.blank? ? respond_with(sites_list, status: 204) : respond_with(sites_list[0, @limit])
      else
        if sites_list.first.key? (:message)
          respond_with(sites_list.first, status: 404)
        else
          respond_with(sites_list[0, @limit])
        end
      end
    end

    def show
      sites = Sites.new
      site = sites.show(params[:appliance_id],params[:id])
      respond_with(site)
      return
      site.first.key? (:message) ? respond_with(site.first, status: 404) : respond_with(site)
    end
  end
end
