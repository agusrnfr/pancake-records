Rails.application.routes.draw do
  devise_for :users, skip: [:registrations]

  
  get "up" => "rails/health#show", as: :rails_health_check

  root "home#index"

  namespace :backoffice do
    root :to => "menu#index"

    devise_scope :user do
      resource :registration,
        only: [:edit, :update],
        path: 'users',
        controller: '/users/registrations',
        as: :user_registration
    end

		resources :users 
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
