require 'test_helper'
require 'webmock/test_unit'
require 'robut'
require 'robut-weather'

class Robut::Plugin::WeatherTest < Test::Unit::TestCase

  def setup
    @connection = Robut::ConnectionMock.new
    @presence = Robut::PresenceMock.new(@connection)
    @plugin = Robut::Plugin::Weather.new(@presence)
  end

  def teardown
    Robut::Plugin::Weather.default_location = nil
    Robut::Plugin::Weather.api_key = nil
  end

  def test_handle_no_weather
    @plugin.handle(Time.now, "John", "lunch?")
    assert_equal( [], @plugin.reply_to.replies )

    @plugin.handle(Time.now, "John", "?")
    assert_equal( [], @plugin.reply_to.replies )
  end

  def test_handle_no_location_no_default
    @plugin.handle(Time.now, "John", "weather")
    assert_equal( ["Error getting weather: I don't have a default location!"], @plugin.reply_to.replies )
  end

  def test_handle_no_api_key
    Robut::Plugin::Weather.default_location = "12345"
    @plugin.handle(Time.now, "John", "weather")
    assert_equal( ["Error getting weather: API Key has not been set."], @plugin.reply_to.replies )
  end

  def test_handle_default_location_zip
    Robut::Plugin::Weather.default_location = "12345"
    Robut::Plugin::Weather.api_key = ""

    stub_request(:get, "http://api.wunderground.com/api//conditions/q/12345.json").to_return(:body => File.open(File.expand_path("../fixtures/12345.json", __FILE__), "r").read)

    @plugin.handle(Time.now, "John", "weather")
    assert_equal( ["Weather for Schenectady, NY: Mostly Cloudy, Current Temperature 51.1 F (10.6 C), Wind From the South at 1.0 MPH Gusting to 5.0 MPH. Full forecast: http://www.wunderground.com/US/NY/Schenectady.html"], @plugin.reply_to.replies )
  end

  def test_handle_default_location_city_state
    Robut::Plugin::Weather.default_location = "NY/Schenectady"
    Robut::Plugin::Weather.api_key = ""

    stub_request(:get, "http://api.wunderground.com/api//conditions/q/NY/Schenectady.json").to_return(:body => File.open(File.expand_path("../fixtures/12345.json", __FILE__), "r").read)

    @plugin.handle(Time.now, "John", "weather")
    assert_equal( ["Weather for Schenectady, NY: Mostly Cloudy, Current Temperature 51.1 F (10.6 C), Wind From the South at 1.0 MPH Gusting to 5.0 MPH. Full forecast: http://www.wunderground.com/US/NY/Schenectady.html"], @plugin.reply_to.replies )
  end

  def test_handle_location_zip
    Robut::Plugin::Weather.default_location = ""
    Robut::Plugin::Weather.api_key = ""

    stub_request(:get, "http://api.wunderground.com/api//conditions/q/12345.json").to_return(:body => File.open(File.expand_path("../fixtures/12345.json", __FILE__), "r").read)

    @plugin.handle(Time.now, "John", "weather 12345")
    assert_equal( ["Weather for Schenectady, NY: Mostly Cloudy, Current Temperature 51.1 F (10.6 C), Wind From the South at 1.0 MPH Gusting to 5.0 MPH. Full forecast: http://www.wunderground.com/US/NY/Schenectady.html"], @plugin.reply_to.replies )
  end

  def test_handle_location_city_state
    Robut::Plugin::Weather.default_location = ""
    Robut::Plugin::Weather.api_key = ""

    stub_request(:get, "http://api.wunderground.com/api//conditions/q/NY/Schenectady.json").to_return(:body => File.open(File.expand_path("../fixtures/12345.json", __FILE__), "r").read)

    @plugin.handle(Time.now, "John", "weather NY/Schenectady")
    assert_equal( ["Weather for Schenectady, NY: Mostly Cloudy, Current Temperature 51.1 F (10.6 C), Wind From the South at 1.0 MPH Gusting to 5.0 MPH. Full forecast: http://www.wunderground.com/US/NY/Schenectady.html"], @plugin.reply_to.replies )
  end

  def test_handle_invalid_location
    Robut::Plugin::Weather.default_location = ""
    Robut::Plugin::Weather.api_key = ""

    stub_request(:get, "http://api.wunderground.com/api//conditions/q/0.json").to_return(:body => File.open(File.expand_path("../fixtures/0.json", __FILE__), "r").read)

    @plugin.handle(Time.now, "John", "weather 0")
    assert_equal( ["Error getting weather: Invalid Location"], @plugin.reply_to.replies )
  end

end