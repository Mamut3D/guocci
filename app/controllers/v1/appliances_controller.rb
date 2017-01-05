module V1
  class AppliancesController < ApplicationController
    def index
      appliances = Appliances.new(cache: cache_manager)
      appliances_list = appliances.list
      appliances_list.blank? ? respond_with({}, status: 204) : respond_with(appliances_list[0, @limit])
    end

    def show
      appliances = Appliances.new(cache: cache_manager)
      respond_with(appliances.show(params['id']))
    end
  end
end
