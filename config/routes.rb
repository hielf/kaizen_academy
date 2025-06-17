Rails.application.routes.draw do
  # Devise routes for Users (which includes Student and Admin via STI)
  devise_for :users, controllers: {
    registrations: 'users/registrations', # Optional: if you want custom Devise controllers
    sessions: 'users/sessions'           # Optional: if you want custom Devise controllers
  }
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Define the root route
  root to: "home#index"

  get '/admin/dashboard', to: 'admin_dashboards#show', as: :admin_dashboard
  get '/student/dashboard', to: 'student_dashboards#show', as: :student_dashboard

  match "/404", to: "errors#not_found", via: :all
  match "/500", to: "errors#internal_server_error", via: :all

  # Catch-all route to redirect
  match "*path", to: "errors#not_found", via: :all
end