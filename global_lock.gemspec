Gem::Specification.new do |s|
  s.name = "global_lock"
  s.version = "0.0.0"
  s.summary = "Global Lock"
  s.description = "Global Lock"
  s.authors = ["Samuel Ballan"]
  s.email = ["sgb4622@gmail.com"]
  s.files = ["lib/global_lock.rb"]
  s.license = "MIT"

  s.add_dependency "redis"
  s.add_dependency "connection_pool"
  s.add_development_dependency "rspec"
  s.add_development_dependency "mock_redis"
end
