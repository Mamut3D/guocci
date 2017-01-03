module V1
  class TestOcciController < ApplicationController
    def index
      instances = Instances.new(cache: cache_manager)
      respond_with(instances.all_test_method('247G0:4450G0', @cert))
    end
  end
end
