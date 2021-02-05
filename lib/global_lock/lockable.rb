module GlobalLock
  module Lockable
    def self.included(other_mod)
      # This pattern lets us have instance _and_ class methods in this module
      other_mod.extend ClassMethods
    end

    def lock_id
      send(self.class.lock_id_name)
    end

    def lock(opts={})
    GlobalLock.singleton.lock(lock_id, opts)
    end

    def unlock(key)
      GlobalLock.singleton.unlock(lock_id, key)
    end

    def with_lock(existing_key=nil, opts={}, &block)
    GlobalLock.singleton.with_lock(lock_id, existing_key, opts, &block)
    end

    # This pattern lets us have instance _and_ class methods in this module
    module ClassMethods
      def lock_id_name
        @lock_id_name || :id
      end

      def set_lock_id_name(lock_id_name)
        raise "Lock name must be symbol" unless lock_id_name.is_a? Symbol

        @lock_id_name = lock_id_name
      end
    end
  end
end