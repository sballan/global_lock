module GlobalLock
  class Config
    attr_accessor :default_ttl, :default_retry_time, :default_backoff_time, :redis_prefix, :redis_connection, :redis_pool

    def initialize(opts = {})
      opts.each do |attr_name, attr_value|
        self.send("#{attr_name}=".to_sym, attr_value)
      end
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
  end
end
