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
    assert_equal( ["Error getting weather: Wunderground::MissingAPIKey"], @plugin.reply_to.replies )
  end

end