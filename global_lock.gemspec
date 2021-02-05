Gem::Specification.new do |s|
  s.name = "global_lock"
  s.version = "0.0.5"
  s.summary = "Global Lock"
  s.description = "Global Lock"
  s.authors = ["Samuel Ballan"]
  s.email = ["sgb4622@gmail.com"]
  s.files = `git ls-files`.split("\n")
  s.test_files = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.require_paths = ["lib"]
  s.license = "MIT"

  s.add_dependency "redis"
  s.add_dependency "connection_pool"
  s.add_development_dependency "rspec"
  s.add_development_dependency "mock_redis"
end
