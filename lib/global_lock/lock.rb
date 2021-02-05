class GlobalLock::Lock
  attr_reader :config

  def initialize(opts = {})
    @config = GlobalLock::Config.new(opts)
  end

  def with_lock(name, existing_key=nil, opts={}, &block)
    opts = config.lock_opts.merge(opts)
    raise ArgumentError.new("Block required") unless block_given?

    ret_val = nil

    if !existing_key.nil && correct_key?(name, existing_key)
      ret_val = block.call(existing_key)
    elsif !existing_key.nil?
      raise GlobalLock::Errors::FailedToLockError.new("Used incorrect existing key")
    else
      key = lock(name, opts)
      raise GlobalLock::Errors::FailedToLockError.new("Failed to acquire lock") if (key == false)

      ret_val = block.call(key)

      unlock_success = unlock(name, key)
      raise GlobalLock::Errors::FailedToUnlockError.new("Failed to unlock") unless unlock_success
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
    elsif retry_time > 0
      sleep backoff_time

      # Note: really, the backoff factor should be multiplied by retry_wait

      lock(
        name,
        ttl: ttl,
        retry_time: retry_time - backoff_time,
        backoff_time: backoff_time * 2 * rand(0.5..1.5)
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
    return false unless name && possible_key && !name.empty? && !possible_key.empty?

    actual_key = fetch_lock_key(name)
    possible_key == actual_key
  end

  protected

  def write_lock(name, key, ex: nil)
    ex ||= config.default_ttl
    raise ArgumentError.new("Cannot write_lock with blank name") if name.empty?

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
