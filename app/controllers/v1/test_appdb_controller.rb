module V1
  class TestAppdbController < ApplicationController
    def index
      respond_with(Utils::AppdbReader.all)
    end
  end
end
