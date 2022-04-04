
ruby ">= 2.6"

source 'https://rubygems.org'

gemspec

gem 'rails', '5.2.4'
gem 'bson', '4.14.1'
gem 'mongoid', git: 'https://github.com/shoplineapp/mongoid', tag: 'v7.0.6-patched'
gem 'mongo', git: 'https://github.com/shoplineapp/mongo-ruby-driver', branch: 'feature/mongo-crypt-schema-map-init'
gem 'hashie'

# For security patch
gem 'nokogiri', '>= 1.13.2'

group :test do
  gem 'rspec'
  gem 'mongoid-rspec'
  gem 'faker'
end
