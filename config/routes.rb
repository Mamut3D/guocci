Rails.application.routes.draw do
  namespace :v1 do
    # TODO: remove from final project
    resources :test_appdb, only: [:index]

    resources :appliances, only: [:index, :show] do
      resources :sites, only: [:index, :show] do
        resources :flavours, only: [:index, :show]
      end
    end

    resources :user, only: [:show] do
      resources :credentials, only: [:index, :show, :create, :delete]
    end

    resources :sites, only: [:index] do
      resources :instances, only: [:index, :show, :create, :delete] do
        resources :disks, only: [:index, :show, :create, :delete]
        resources :interfaces, only: [:index, :show, :create, :delete]
      end

      resources :networks, only: [:index, :show, :create, :delete]
      resources :storages, only: [:index, :show, :create, :delete]
    end
  end
end
