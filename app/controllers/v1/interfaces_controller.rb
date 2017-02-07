module V1
  class InterfacesController < ApplicationController
    def index
      interfaces = Interfaces.new(cache: cache_manager, service_id: params[:site_id], cert: @cert)
      interfaces_list = interfaces.list(params[:instance_id])
      respond_with(interfaces_list)
      # respond_with(interfaces_list[0, @limit])
    end

    def show
      # interfaces = Interfaces.new(cache: cache_manager, service_id: params[:site_id], cert: @cert)
      # respond_with(interfaces.show(params[:id]))
    end

    def destroy
      # interfaces = Interfaces.new(cache: cache_manager, service_id: params[:site_id], cert: @cert)
      # TODO: check respond with return codes
      # respond_with(interfaces.destroy(params[:id]))
    end

    def create
      # interfaces = Interfaces.new(cache: cache_manager, service_id: params[:site_id], cert: @cert)
      # instance_url = interfaces.create(params['instance'])
      # respond_with({ locations: [instance_url] }, status: 201, location: instance_url)
    end
  end
end
