module V1
  class TestAppdbController < ApplicationController
    respond_to :json

    def index
      respond_with(Utils::AppdbReader.all)
      # respond_with(Utils::AppdbReader.appdb_raw_request)
    end
  end
end
