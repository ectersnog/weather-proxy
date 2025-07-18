# frozen_string_literal: true

module V1
  class WeatherController < ApplicationController
    def current
      result = Weather::Current.call(query: params.expect(:q))
      if result.success?
        render locals: { current: result.success }
      else
        render json: { errors: result.failure }, status: :not_found
      end
    end
  end
end
