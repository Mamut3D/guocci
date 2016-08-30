module V1
  class SitesController < ApplicationController
    respond_to :json

    def index
      sites = Sites.new
      sites_list = sites.list
      sites_list.blank? ? respond_with(sites_list, status: 204) : respond_with(sites_list[0, @limit])
    end

    def show
      sites = Sites.new
      site = sites.show(params[:id])
      if site.blank?
        respond_with({ message: "Site with ID #{params[:id]} could not be found!" }, status: 404)
      else
        respond_with(site)
      end
    end
  end
end
