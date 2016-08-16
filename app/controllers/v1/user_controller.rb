module V1
  class UserController  < ApplicationController
    def index
      render html: "hello, world!"
    end
    def show
    end
  end
end
