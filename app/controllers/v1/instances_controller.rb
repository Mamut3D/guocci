module V1
  class InstancesController < ApplicationController
    respond_to :json

    def index
      instances = Instances.new(cache: cache_manager)
      instances_list = instances.list(params[:site_id], @cert)
      respond_with(instances_list[0, @limit])
    end

    def show
      instances = Instances.new(cache: cache_manager)
      respond_with(instances.show(params[:site_id], @cert, params[:id]))
    end

    def destroy
      # instances = Instances.new(cache: cache_manager)
      respond_with({ message: 'aaaa' }, status: 404)
      # respond_with(instances.destroy(params[:site_id], @cert, params[:id]))
    end

    def create
      respond_with('create')
    end
  end
end
