# frozen_string_literal: true

require "rails"
require "mongoid"

module MongoidClientSideEncryption
  class Railtie < Rails::Railtie
    initializer "z_mongoid_client_side_encryption.register-field-options" do
      Mongoid::Fields.option(:encrypt) do |klass, field, options|
        Models::Field.add(klass, field, options) if options == true || options.is_a?(Hash)
      end
    end
  end
end
