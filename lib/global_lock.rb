require 'securerandom'

require 'redis'
require 'connection_pool'

module GlobalLock
  extend self

  attr_reader :config

  def singleton
    @singleton = GlobalLock::Lock.new(config)
  end

  def config(&block)
    @config ||= GlobalLock::Config.new

    if block_given?
      block.call(@config)
    else
      @config
    end
  end
end

require_relative './global_lock/config'
require_relative './global_lock/errors'
require_relative './global_lock/lock'
require_relative './global_lock/lockable'
