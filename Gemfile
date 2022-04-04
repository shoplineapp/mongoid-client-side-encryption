source 'https://rubygems.org'

gemspec

gem 'bson', '4.14.1'
gem 'mongoid', git: 'https://github.com/shoplineapp/mongoid', tag: 'v7.0.6-patched'
gem 'mongo', git: 'https://github.com/shoplineapp/mongo-ruby-driver', branch: 'feature/mongo-crypt-schema-map-init'
gem 'hashie'

group :test do
  gem 'rspec'
  gem 'mongoid-rspec'
  gem 'factory_bot'
  gem 'faker'
  gem 'coveralls', require: false
  gem 'generator_spec'
end
