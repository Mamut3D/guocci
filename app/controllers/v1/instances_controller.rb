module V1
  class InstancesController < ApplicationController
    respond_to :json

    def index
      instances = Instances.new(cache: cache_manager)
      endpoint = instances.list(params[:site_id])
      occi_client(endpoint)
      #respond_with(@user_cert)
      #occi_client(endpoint)
      respond_with(@client.describe "compute")#@client.)
    end

    def create
      respond_with("create")
    end

    def show
      respond_with("show")
    end
  end
end
