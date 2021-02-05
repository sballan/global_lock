module GlobalLock
  module Lockable
    def lock_id
      send(self.class.lock_id_name)
    end

    def lock(opts={})
      Lock.lock(lock_id, opts)
    end

    def unlock(key)
      Lock.unlock(lock_id, key)
    end

    def with_lock(existing_key=nil, opts={}, &block)
      Lock.with_lock(lock_id, existing_key, opts, &block)
    end

    def self.lock_id_name
      @lock_id_name || :id
    end

    def self.set_lock_id_name(lock_id_name)
      raise "Lock name must be symbol" unless lock_id_name.is_a? Symbol

      @lock_id_name = lock_id_name
    end
  end
end