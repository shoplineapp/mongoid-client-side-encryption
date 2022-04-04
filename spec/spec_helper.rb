# frozen_string_literal: true

ENV['RUBY_ENV'] = 'test'

require 'rails'
require 'bundler'
require 'mongoid'

Mongoid.load!(
  File.join(Dir.pwd, 'spec', 'config', 'mongoid.yml'),
  ENV['RUBY_ENV'],
)

Bundler.require(:default, :test)

require_relative '../lib/mongoid-client-side-encryption'

MongoidClientSideEncryption::Railtie.initializers.each(&:run)

RSpec.configure do |config|
  config.order = :random
  config.filter_run focus: true
  config.run_all_when_everything_filtered = true

  config.include FactoryBot::Syntax::Methods

  Mongoid.raise_not_found_error = false
end
