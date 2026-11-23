Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  root "organizations#index"

  resources :organizations, only: [ :index, :show, :new, :create, :edit, :update ] do
    resources :check_runs, only: [ :create ]
    get :evidence, on: :member, to: "evidence#show"
  end

  resources :results, only: [ :show ] do
    resources :remediations, only: [ :create ]
  end

  resources :remediations, only: [ :edit ] do
    member do
      patch :approve
      patch :reject
    end
  end
end
