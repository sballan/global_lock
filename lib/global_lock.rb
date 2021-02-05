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

require 'global_lock/config'
require 'global_lock/errors'
require 'global_lock/lock'
require 'global_lock/lockable'
