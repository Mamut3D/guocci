module V1
  class InstancesController < ApplicationController
    respond_to :json

    def index
      instances = Instances.new(cache: cache_manager)
      respond_with(instances.list(params[:site_id], @cert))
    end

    def create
      respond_with("create")
    end

    def show
      respond_with("show")
    end

    private
  end
end
