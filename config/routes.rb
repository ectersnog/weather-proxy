Rails.application.routes.draw do
  namespace :v1 do
    get "/weather", to: "weather#current", defaults: { format: :json }
  end
  get "up" => "rails/health#show", as: :rails_health_check
end
