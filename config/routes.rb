Rails.application.routes.draw do
  # Devise routes for Users (which includes Student and Admin via STI)
  devise_for :users, controllers: {
    registrations: 'users/registrations'
  }
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Define the root route
  root to: "home#index"

  # Admin routes
  namespace :admin do
    resources :students, only: [:index, :show, :destroy]
    resources :schools do
      resources :terms do
        resources :courses
        resources :licenses do
          collection do
            post :generate
          end
        end
      end
    end
  end

  get '/student/dashboard', to: 'student_dashboards#show', as: :student_dashboard

  match "/404", to: "errors#not_found", via: :all
  match "/500", to: "errors#internal_server_error", via: :all

  # Catch-all route to redirect
  match "*path", to: "errors#not_found", via: :all
end