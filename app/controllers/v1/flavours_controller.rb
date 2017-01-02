module V1
  class FlavoursController < ApplicationController
    def index
      flavours = Flavours.new(cache: cache_manager)
      flavour_list = flavours.list(params[:appliance_id], params[:site_id])
      flavour_list.blank? ? respond_with(nil, status: 204) : respond_with(flavour_list[0, @limit])
    end

    def show
      flavours = Flavours.new(cache: cache_manager)
      respond_with(flavours.show(params[:appliance_id], params[:site_id], params[:id]))
    end
  end
end
