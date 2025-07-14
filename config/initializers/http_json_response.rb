# frozen_string_literal: true

require 'http'
require 'json'

module HTTP
  class Response
    def json
      JSON.parse(body.to_s)
    end
  end
end
