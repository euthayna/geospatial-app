# frozen_string_literal: true

Rails.application.routes.draw do
  root 'tickets#index'

  namespace :api do
    resources :tickets, only: [:create]
  end

  resources :tickets, only: %i[index show]
end
