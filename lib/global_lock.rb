require 'redis'
require 'connection_pool'

module GlobalLock
  extend self

  attr_reader :config

  def config=(config_opts)
    @config = GlobalLock::Config.new(config_opts)
  end

  def config(&block)
    block.call(@config)
  end
end

require_relative './global_lock/config'
require_relative './global_lock/errors'
require_relative './global_lock/lock'
require_relative './global_lock/lockable'
