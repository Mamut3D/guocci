module V1
  class InstancesController < ApplicationController
    def index
      instances = Instances.new(cache: cache_manager, service_id: params[:site_id], cert: @cert)
      instances_list = instances.list
      respond_with(instances_list[0, @limit])
    end

    def show
      instances = Instances.new(cache: cache_manager, service_id: params[:site_id], cert: @cert)
      respond_with(instances.show(params[:id]))
    end

    def destroy
      instances = Instances.new(cache: cache_manager, service_id: params[:site_id], cert: @cert)
      # TODO: check respond with return codes
      respond_with(instances.destroy(params[:id]))
    end

    def create
      instances = Instances.new(cache: cache_manager, service_id: params[:site_id], cert: @cert)
      instance_url = instances.create(params['instance'])
      respond_with({ locations: [instance_url] }, status: 201, location: instance_url)
    end
  end
end
