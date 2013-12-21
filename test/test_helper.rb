require 'robut'
require 'test/unit'
require 'presence_mock'
require 'connection_mock'

Robut::ConnectionMock.configure do |config|
  config.nick = "Robut t. Robot"
  config.mention_name = "robut"
end