module V1
  class AppliancesController < ApplicationController
    respond_to :json

    def index
      vaprovider = vaproviders_from_appdb.select { |prov| prov['id'] == params[:site_id] }.first
      if vaprovider
        appliances = vaprovider_appliances(vaprovider)
        if appliances.blank?
          respond_with(status: 204)
        else
          respond_with(appliances[0, @limit])
        end
      else
        response = {
          message: "Site with ID #{params[:site_id]} could not be found!"
        }
        respond_with(response, status: 400)
      end
    end

    def show
      vaprovider = vaproviders_from_appdb.select { |prov| prov['id'] == params[:site_id] }.first
      if vaprovider
        appliances = vaprovider_appliances(vaprovider)
        appliance = appliances.select { |appl| appl['id'] == params[:id]}
        if appliance
          respond_with(appliance)
        else
          response = {
            message: "Appliance with ID #{params[:id]} could not be found at site #{params[:site_id]}!"
          }
          respond_with(response, status: 400)
          return
        end
      else
        response = {
          message: "Site with ID #{params[:site_id]} could not be found!"
        }
        respond_with(response, status: 400)

      end
      return
    end
  end
end
