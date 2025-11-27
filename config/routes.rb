Rails.application.routes.draw do
  devise_for :users, controllers: {
  registrations: "users/registrations"
  }
  
  get "up" => "rails/health#show", as: :rails_health_check

  root "home#index"

  namespace :backoffice do
    root :to => "menu#index"

		resources :users, only: [:index, :new, :create, :edit, :update, :destroy, :show] 
		resources :products do
			member do
				patch :increment_stock
				patch :decrement_stock
				patch :soft_delete
        patch :restore
			end
		end
  	resources :sales, only: [:index]
  end
end
