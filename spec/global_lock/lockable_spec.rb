require "spec_helper"

describe GlobalLock::Lockable do
  before do
    @mock_redis = MockRedis.new
    GlobalLock.config do |c|
      c.redis_connection     = @mock_redis
      c.default_ttl          = 60 * 5
      c.default_retry_time   = 1
      c.default_backoff_time = 1
    end
  end

  let(:test_lock_name) { 'test_lock_name' }
  let(:redis_test_lock_name) { GlobalLock.config.redis_prefix + test_lock_name }

  after(:each) do
    @mock_redis.flushdb
  end

  class MockLockable
    include GlobalLock::Lockable
    set_lock_id_name :id

    def id
      @id ||= SecureRandom.uuid
    end
  end

  context 'included' do
    let(:lockable) { MockLockable.new }
    describe 'lock' do
      it 'returns the lock key' do
        key = lockable.lock
        expected_key = @mock_redis.get(GlobalLock.config.redis_prefix + lockable.id)

        expect(key).to eql(expected_key)
      end

      it 'returns false if already locked' do
        successful_key = lockable.lock
        failed_key = lockable.lock

        expect(successful_key).to be_a String
        expect(failed_key).to eql(false)
      end
    end
  end


end
