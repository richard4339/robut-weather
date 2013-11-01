require 'nokogiri'
require 'json'
require 'open-uri'

# What's the weather?
class Robut::Plugin::Weather
  include Robut::Plugin
  class << self

  end

  # Returns a description of how to use this plugin
  desc "weather - returns the weather in the default location for today"

  match /^weather$/, :sent_to_me => true do |query|
    begin
      reply "#{current_conditions} - from http://www.wunderground.com"
    rescue Exception => msg
      puts msg
      reply "Error scraping Weather Underground website"
    end
  end

  # Get today's current_conditions
  def current_conditions()
    current_conditions = "Unknown"
    uri = "http://api.wunderground.com/api/[API KEY]/conditions/q/IL/Sycamore.json"
    begin
      parsed = JSON.parse(open(uri).read)
    rescue => e
      case e
        when OpenURI::HTTPError
          parsed = JSON.parse(open(uri).read)
        else
          raise e
      end
    end
    current_conditions = "Weather for Sycamore, IL: " + parsed["current_observation"]["weather"] + ", Current Temperature " + parsed["current_observation"]["temperature_string"] + ", Wind " + parsed["current_observation"]["wind_string"]
    current_conditions
  end
end
