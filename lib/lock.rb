module GlobalLock
  class Lock
    attr_reader :config

    def initialize(config)
      self.config = config
    end

    def with_lock(name, existing_key=nil, opts={}, &block)
      opts = config.lock_default_opts.merge(opts)
      raise ArgumentError.new("Block required") unless block.present?

      ret_val = nil

      if existing_key.present? && correct_key?(name, existing_key)
        ret_val = block.call(existing_key)
      elsif existing_key.present?
        raise Errors::FailedToLockError.new("Used incorrect existing key")
      else
        key = lock(name, opts)
        raise Errors::FailedToLockError.new("Failed to acquire lock") if (key == false)

        ret_val = block.call(key)

        unlock_success = unlock(name, key)
        raise Errors::FailedToUnlockError.new("Failed to unlock") unless unlock_success
      end

      ret_val
    end

    def lock(name, opts={})
      opts = config.lock_opts.merge(opts)
      ttl, retry_time, backoff_time = opts.values_at(:ttl, :retry_time, :backoff_time)

      key = SecureRandom.uuid
      success = write_lock(name, key, ex: ttl)

      if success
        key
      elsif retry_time > 0.seconds
        sleep backoff_time

        # Note: really, the backoff factor should be multiplied by retry_wait 

        lock(
          name,
          ttl: ttl,
          retry_time: retry_time - backoff_time,
          backoff_time: retry_wait * 2 * rand(0.5..1.5)
        )
      else
        false
      end
    end

    def unlock(name, key)
      if correct_key?(name, key)
        delete_lock(name)
      else
        false
      end
    end

    def correct_key?(name, possible_key)
      return false unless name.present? && possible_key.present?

      actual_key = fetch_lock_key(name)
      possible_key == actual_key
    end

    protected

    def write_lock(name, key, ex: nil)
      ex ||= config.default_ttl
      raise ArgumentError.new("Cannot write_lock with blank name") if name.blank?

      res = config.with_redis do |redis|
        redis.set(config.redis_prefix + name, key, ex: ex, nx: true)
      end
      res == true
    end

    def fetch_lock_key(name)
      config.with_redis do |redis|
        redis.get(config.redis_prefix + name)
      end
    end

    def delete_lock(name)
      res = config.with_redis do |redis|
        redis.del(config.redis_prefix + name)
      end
      res == 1
    end
  end
end
