module V1
  class AppliancesController < ApplicationController
    respond_to :json

    def index
      appliances = Appliances.new
      appliances_list = appliances.list
      appliances_list.blank? ? respond_with({}, status: 204) : respond_with(appliances_list[0, @limit])
    end

    def show
      appliances = Appliances.new
      appliance = appliances.show(params['id'])
      appliance.blank? ? respond_with({ message: "appliance #{params[:id]} not found!" }, status: 404) : respond_with(appliance)#[0, @limit])
    end
  end
end
