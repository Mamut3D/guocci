module V1
  class FlavoursController < ApplicationController
    respond_to :json

    def index
      flavours = Flavours.new
      flavour_list = flavours.list(params[:appliance_id],params[:site_id])
      flavour_list.blank? ? respond_with(flavour_list, status: 204) : respond_with(flavour_list)#[0, @limit])
    end

    def show
      flavours = Flavours.new
      flavour = sites.show(params[:id])
      if site.blank?
        respond_with({ message: "Site with ID #{params[:id]} could not be found!" }, status: 404)
      else
        respond_with(site)
      end
    end
  end
end
