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
  def usage
    [
        "#{at_nick} weather - returns the current conditions in the default location",
        "#{at_nick} weather <location> - returns the current conditions for <location>",
        "#{at_nick} radar - returns the radar for the default location",
        "#{at_nick} radar <location> - returns the radar for <location>"
    ]
  end

  def handle(time, sender_nick, message)
    if sent_to_me?(message)
      words = words(message)

      i = words.index("radar")
      unless i.nil?
        l = location(words(message)[i + 1])
        if l.nil?
          error_output "I don't have a default location!"
          return
        end

        begin
          o = radar(l)
          reply o unless o.nil? || o == ""
        rescue Exception => msg
          puts msg
          error_output(msg)
        end
      end

      i = words.index("weather")
      # ignore messages that don't have "weather" in them
      return if i.nil?

      l = location(words(message)[i + 1])
      if l.nil?
        error_output "I don't have a default location!"
        return
      end

      begin
        o = current_conditions(l)
        reply o unless o.nil? || o == ""
      rescue Exception => msg
        puts msg
        error_output(msg)
      end
    end
  end

  def location(x)
    x = self.class.default_location if x.nil?
    x
  end

  def error_output(m)
    reply "Error getting weather: #{m}"
  end

  # Get today's current_conditions
  def current_conditions(l)
    current_conditions = "Unknown"
    w_api = Wunderground.new(self.class.api_key)
    begin
      parsed = w_api.conditions_for(l)
      w = parsed["current_observation"]

    rescue => e
      case e
        when Wunderground::MissingAPIKey
          error_output "API Key has not been set."
          return ""
        else
          raise e
      end
    end

    if w.nil?
      error_output "Invalid Location"
      return ""
    end

    current_conditions = "Weather for #{w['display_location']['full']}: #{w['weather']}, Current Temperature #{w['temperature_string']}, Wind #{w['wind_string']}. Full forecast: #{w['forecast_url']}"
    current_conditions
  end

  # Get radar image
  def radar(l)

    w_api = Wunderground.new(self.class.api_key)
    return "#{w_api.base_api_url}animatedradar/q/#{l}.gif?num=6&delay=50&interval=30"
  end
end