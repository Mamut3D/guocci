module V1
  class TestAppliancesController < ApplicationController
    respond_to :json

    def index
      #respond_with(Utils::AppdbReader.appliances)
      respond_with(Utils::AppdbReader.all)
    end
  end
end
