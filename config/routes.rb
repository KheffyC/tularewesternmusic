Rails.application.routes.draw do
  devise_for :directors

  #  Home Page Route
  get 'home/index'
  root "home#index"

  # About Page Route
  get 'home/about'

  # Admin Routes for ActiveAdmin
  namespace :admin do
    resources :programs
    resources :schools
    resources :districts
    resources :boosters
    resources :fundraisers
    resources :galleries do
      post :upload_image, on: :member
    end
    resources :staff_members

    root to: "schools#index"
  end

  # Program index routes remain available for admin-facing usage if needed
  resources :programs, only: [:index]

  # School routes for each school
  resources :schools

  resources :amazon_pdfs, path: 'pdfs' do
    get :student_forms, on: :collection
  end

  resources :galleries

  resources :fundraisers
  resources :staff_members, only: [:index]
  resources :boosters, only: [:index]
  resources :donations do
    get :payment_confirmation, on: :collection, path: '/payment_confirmation/:id'
  end

  # Booster routes for each booster
  # resources :boosters

  # Contact routes for each contact
  resources :contacts
end
