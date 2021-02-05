class GlobalLock::Config
  attr_accessor :default_ttl,
                :default_retry_time,
                :default_backoff_time,
                :redis_prefix,
                :redis_connection,
                :redis_pool

  def initialize(opts = {})
    self.default_ttl          = opts[:default_ttl]          || 60 * 60 * 24
    self.default_retry_time   = opts[:default_retry_time]   || 30
    self.default_backoff_time = opts[:default_backoff_time] || 0.01
    self.redis_prefix         = opts[:redis_prefix]         || "GlobalLock/"
    self.redis_connection     = opts[:redis_connection]     || Redis.new
    self.redis_pool           = opts[:redis_pool]           || ConnectionPool.new { self.redis_connection }
  end

  def lock_opts
    {
      ttl: default_ttl,
      retry_time: default_retry_time,
      backoff_time: default_backoff_time,
      redis_prefix: redis_prefix,
      redis_connection: redis_connection,
      redis_pool: redis_pool
    }
  end

  def with_redis(&block)
    redis_pool.with(&block)
  end
end
