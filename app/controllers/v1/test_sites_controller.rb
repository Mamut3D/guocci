module V1
  class TestSitesController < ApplicationController
    respond_to :json

    def index
      respond_with(Utils::AppdbReader.sites_and_flavours)
    end
  end
end
