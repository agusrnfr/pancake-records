Rails.application.routes.draw do
  devise_for :users, skip: [:registrations]
  mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development?
  
  get "up" => "rails/health#show", as: :rails_health_check

  root "home#index"
  get "productos/:id", to: "home#show", as: :product

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
