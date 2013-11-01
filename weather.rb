require 'json'
require 'open-uri'

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
    case words(query).first
    when 'radar'
       if words[1]).nil?
         l = location
       else
         l = location(words[1])
       end 
       output("#{url}animatedradar/q/#{l}.gif")
    else
        if words(query).first.nil?
         l = location
       else
         l = location(words(query).first)
       end 
        begin
          output(current_conditions(l))
        rescue Exception => msg 
          puts msg
          reply "Error scraping Weather Underground website"
        end
    end
  end
  
  def url
     return "http://api.wunderground.com/api/#{self.class.api_key}/"
  end
  
  def location(x = self.class.default_location)
     x
  end
  
  def output(m)
    reply "#{m} - from http://www.wunderground.com"
  end

  # Get today's current_conditions
  def current_conditions(l, date = Date.today)
    current_conditions = "Unknown"
    date = Date.today if date.nil?
    month = Date::MONTHNAMES[date.month]
    day = date.mday
    uri = "#{url}conditions/q/#{l}.json"
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
    current_conditions = "Weather for " + parsed["current_observation"]["display_location"]["full"] + ": " + parsed["current_observation"]["weather"] + ", Current Temperature " + parsed["current_observation"]["temperature_string"] + ", Wind " + parsed["current_observation"]["wind_string"]
    current_conditions
  end
end