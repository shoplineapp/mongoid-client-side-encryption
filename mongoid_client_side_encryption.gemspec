$:.push File.expand_path('../lib', __FILE__)

require "mongoid_client_side_encryption/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "mongoid-client-side-encryption"
  s.version     = MongoidClientSideEncryption::VERSION
  s.authors     = ["Philip Yu"]
  s.email       = ["philip@shoplineapp.com"]
  s.homepage    = "https://shopline.hk"
  s.summary     = "Mongoid support on Client-side Encryption"
  s.description = "Extension on Mongoid for enhancing the developer experience on the usage of client-side encryption"
  s.license     = "MIT"

  s.files = Dir["{app,lib}/**/*", "MIT-LICENSE", "Rakefile"]
  s.test_files = Dir["spec/**/*"]
  s.require_paths = ['lib']

  s.add_dependency "rails"
  s.add_dependency "hashie"
  s.add_dependency "mongoid", ">= 7.0.3"
  s.add_dependency "mongo", ">= 2.12.1"

  s.add_development_dependency "rspec-rails"
  s.add_development_dependency 'simplecov'
end
