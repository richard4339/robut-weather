require 'json'
require 'wunderground'

# What's the weather?
class Robut::Plugin::Weather
  include Robut::Plugin

  class << self
    attr_accessor :default_location
    attr_accessor :api_key
  end

  # Returns a description of how to use this plugin
  desc "weather - returns the weather in the default location for today"

  match /^weather(.*)$/, :sent_to_me => true do |query|
    l = location(words(query).first)
    begin
      output(current_conditions(l))
    rescue Exception => msg
      puts msg
      reply "Error getting weather: #{msg}"
    end
  end

  def location(x)
    x = self.class.default_location if x.nil?
    x
  end

  def output(m)
    reply "#{m} - from http://www.wunderground.com"
  end

  # Get today's current_conditions
  def current_conditions(l)
    current_conditions = "Unknown"
    w_api = Wunderground.new(self.class.api_key)
    begin
      #parsed = w_api.forecast_for(l)
      parsed = w_api.conditions_for(l)
      w = parsed["current_observation"]
    rescue => e
      raise e
    end
    current_conditions = "Weather for #{w['display_location']['full']}: #{w['weather']}, Current Temperature #{w['temperature_string']}, Wind #{w['wind_string']}"
    current_conditions
  end
end