module V1
  class AppliancesController < ApplicationController
    respond_to :json

    def index
      appliances = Appliances.new
      appliances_list = appliances.list(params[:site_id])
      if appliances_list
        appliances_list.blank? ? respond_with({}, status: 204) : respond_with(appliances_list[0, @limit])
      else
        respond_with({ message: "Site with ID #{params[:site_id]} could not be found!" }, status: 400)
      end
    end

    def show
      appliances = Appliances.new
      appliance= appliances.list(params[:site_id], params[:site])
      appliance.key?(:message) ? respond_with(appliance, status: 400) : respond_with(appliance)
    end
  end
end
