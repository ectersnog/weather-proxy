# frozen_string_literal: true

class Geodata
  def self.find(query)
    query_string = if query.match?(/\d{5}/)
      "#{query} + &include=postal"
    elsif query.include?(",")
      city, state = query.split(",")
      "#{city.strip}&states=#{state.strip}"
    else
      query
    end

    ExternalData.location(query_string)
  end
end
