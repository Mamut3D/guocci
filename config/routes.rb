Rails.application.routes.draw do
  namespace :v1 do
    resources :sites, only: [:index, :show] do
      resources :appliances, only: [:show, :index]

      resources :instances, only: [:create, :index, :show, :destroy] do
        resources :disks, only: [:create, :index, :show, :destroy]
        resources :interfaces, only: [:create, :index, :show, :destroy]
      end

      resources :flavours, only: [:index, :show]
      resources :networks, only: [:create, :index, :show, :destroy]
      resources :storages, only: [:create, :index, :show, :destroy]
    end

    resources :user, only: [:index] do
      resources :credentials, only: [:create, :index, :show, :destroy]
    end
  end
end
