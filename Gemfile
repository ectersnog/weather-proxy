# frozen_string_literal: true

source "https://rubygems.org"

gem "bootsnap", require: false
gem "dry-initializer"
gem "dry-initializer-rails"
gem "dry-operation"
gem "http", "~> 5.3"
gem "jbuilder", "~> 2.13"
gem "kamal", require: false
gem "puma", ">= 5.0"
gem "rails", "~> 8.0.2"
gem "rswag-api"
gem "rswag-ui"
gem "solid_cable"
gem "solid_cache"
gem "solid_queue"
gem "sqlite3", ">= 2.1"
gem "thruster", require: false
gem "tzinfo-data", platforms: %i[windows jruby]

group :development, :test do
  gem "brakeman", require: false
  gem "debug", platforms: %i[mri windows], require: "debug/prelude"
  gem "pry"
  gem "rspec-rails"
  gem "rswag-specs"
  gem "rubocop-factory_bot"
  gem "rubocop-rails", require: false
  gem "rubocop-rails-omakase", require: false
  gem "rubocop-rspec", require: false
  gem "rubocop-rspec_rails", require: false
end

group :test do
  gem "shoulda-matchers", "~> 6.0"
end
