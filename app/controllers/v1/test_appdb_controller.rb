module V1
  class TestAppdbController < ApplicationController
    respond_to :json

    def index
      respond_with(Utils::AppdbReader.all)
    end
  end
end
