Rails.application.routes.draw do
  namespace :v1 do
    resources :appliances, only: [:index, :show] do
      resources :sites, only: [:index, :show] do
        resources :flavours, only: [:index, :show]
      end
    end

    resources :user, only: [:show] do
      resources :credentials, only: [:index, :show, :create, :destroy]
    end

    resources :sites, only: [:index] do
      resources :instances, only: [:index, :show, :create, :destroy] do
        resources :disks, only: [:index, :show, :create, :destroy]
        resources :interfaces, only: [:index, :show, :create, :destroy]
      end

      resources :networks, only: [:index, :show, :create, :destroy]
      resources :storages, only: [:index, :show, :create, :destroy]
    end
  end
end
