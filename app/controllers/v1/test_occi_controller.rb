module V1
  class TestOcciController < ApplicationController
    def index
      instances = Instances.new(cache: cache_manager)
      respond_with(instances.all_test_method('75071G0:4454G0', @cert))
    end
  end
end
