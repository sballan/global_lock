require "spec_helper"

describe GlobalLock::Config do

  context "Basics" do
    it "can be created with no arguments" do
      config = GlobalLock::Config.new
      expect(config).to be
    end

    it "has correct defaults" do
      config = GlobalLock::Config.new

      expect(config.default_ttl).to          eql(60 * 60 * 24)
      expect(config.default_retry_time).to   eql(30)
      expect(config.default_backoff_time).to eql(0.01)
      expect(config.redis_prefix).to         eql("GlobalLock/")
    end

    it "can be configured" do
      config = GlobalLock::Config.new(
        default_ttl: 1,
        default_retry_time: 2,
        default_backoff_time: 3,
        redis_prefix: "4"
      )

      expect(config.default_ttl).to eql(1)
      expect(config.default_retry_time).to eql(2)
      expect(config.default_backoff_time).to eql(3)
      expect(config.redis_prefix).to eql("4")
    end
  end
end
