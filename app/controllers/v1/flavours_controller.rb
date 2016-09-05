module V1
  class FlavoursController < ApplicationController
    respond_to :json

    def index
      flavours = Flavours.new
      flavour_list = flavours.list(params[:appliance_id],params[:site_id])
      if flavour_list.first.key? (:message)
        respond_with(flavour_list.first, status: 404)
      else
        flavour_list.blank? ? respond_with(flavour_list, status: 204) : respond_with(flavour_list[0, @limit])
      end
    end

    def show
      flavours = Flavours.new
      flavour = flavours.show(params[:appliance_id], params[:site_id], params[:id])
      flavour.first.key? (:message) ? respond_with(flavour.first, status: 404) : respond_with(flavour)
    end

  end
end
