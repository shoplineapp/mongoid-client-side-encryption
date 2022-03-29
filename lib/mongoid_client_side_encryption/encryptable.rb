# frozen_string_literal: true

require 'active_support/concern'

module MongoidClientSideEncryption
  module Encryptable
    extend ActiveSupport::Concern

    module ClassMethods
      def enable_mongodb_client_encryption(encrypt_metadata: {})
        Model.add(self, encrypt_metadata: encrypt_metadata)
      end
    end
  end
end
