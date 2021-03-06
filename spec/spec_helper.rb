require 'rubygems'
require 'bundler'

ENV['APP_NAME'] = 'Alice'

Bundler.require(:default, :development, :test)

require 'action_subscriber'
require 'active_record'

# Require spec support files
require 'support/user_subscriber'

require 'action_subscriber/rspec'

RSpec.configure do |config|
  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.before(:each, :integration => true) do
    $messages = Set.new
    ::ActionSubscriber::RabbitConnection.connect!
    ::ActionSubscriber.setup_queues!
  end
  config.after(:each, :integration => true) do
    ::ActionSubscriber::RabbitConnection.disconnect!
    ::ActionSubscriber::Base.inherited_classes.each do |klass|
      klass.instance_variable_set("@_queues", nil)
    end
  end
end
