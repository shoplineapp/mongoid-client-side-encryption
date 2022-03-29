# frozen_string_literal: true

require "rails"

module MongoidClientSideEncryption
  class Railtie < Rails::Railtie
    initializer "z_mongoid_client_side_encryption.register-field-options" do
      Mongoid::Fields.option(:encrypt) do |klass, field, options|
        Models::Field.add(klass, field, options)
      end
    end
  end
end
