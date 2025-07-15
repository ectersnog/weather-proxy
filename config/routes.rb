# frozen_string_literal: true

Rails.application.routes.draw do
  namespace :v1 do
    get "/weather", to: "weather#current", defaults: { format: :json }
  end
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'
  get "up" => "rails/health#show", as: :rails_health_check
end
