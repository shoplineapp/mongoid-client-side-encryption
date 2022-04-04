# frozen_string_literal: true

require 'active_support/concern'

module MongoidClientSideEncryption
  module Encryptable
    extend ActiveSupport::Concern

    module ClassMethods
      def enable_mongodb_client_encryption(encrypt_metadata: {})
        Model.add(self, encrypt_metadata: encrypt_metadata)
      end

      def encrypts_field(field_name, options)
        Models::Field.manual_add(self, field_name, options) if options == true || options.is_a?(Hash)
      end
    end
  end
end
