# frozen_string_literal: true

# This file is used by Rack-based servers to start the application.config.ru

require_relative "config/environment"

run Rails.application
Rails.application.load_server
