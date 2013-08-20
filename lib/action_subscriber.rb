require "action_subscriber/version"

require "action_subscriber/decoder"
require "action_subscriber/dsl"
require "action_subscriber/configuration"
require "action_subscriber/rabbit_connection"
require "action_subscriber/router"
require "action_subscriber/subscriber"
require "action_subscriber/threadpool"
require "action_subscriber/worker"
require "action_subscriber/base"

require 'active_support/core_ext'
require 'amqp'
require "celluloid"
require 'thread'

module ActionSubscriber
  ##
  # Public Class Methods
  #

  # Loop over all subscribers and pull messages if there are
  # any waiting in the queue for us.
  #
  def self.auto_pop!
    ::ActionSubscriber::Base.inherited_classes.each do |klass|
      klass.auto_pop!
    end
  end

  # Loop over all subscribers and register each as
  # a subscriber.
  #
  def self.auto_subscribe!
    ::ActionSubscriber::Base.inherited_classes.each do |klass|
      klass.setup_queues!
      klass.auto_subscribe!
    end
  end

  def self.configuration
    @configuration ||= ::ActionSubscriber::Configuration.new
  end

  def self.configure
    yield(configuration) if block_given?
  end

  def self.print_subscriptions
    ::ActionSubscriber::Base.print_subscriptions
  end

  def self.setup_queues!
    ::ActionSubscriber::Base.inherited_classes.each do |klass|
      klass.setup_queues!
    end
  end

  def self.start_queues
    ::ActionSubscriber::RabbitConnection.connect!
    setup_queues!
    print_subscriptions
  end

  def self.start_subscribers
    ::ActionSubscriber::RabbitConnection.connect!
    auto_subscribe!
    print_subscriptions
  end

  ##
  # Class aliases
  #
  class << self
    alias_method :config, :configuration
  end
end