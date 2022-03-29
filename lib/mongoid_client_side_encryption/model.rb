# frozen_string_literal: true

require_relative 'models/field'

module MongoidClientSideEncryption
  class Model
    DEFAULT_ENCRYPT_ALGORITHM = 'AEAD_AES_256_CBC_HMAC_SHA_512-Deterministic'.freeze

    mattr_accessor :encrypted_models

    attr_reader :klass, :namespace
    attr_accessor :fields, :schema

    def initialize(klass)
      @klass = klass
      @namespace = klass.collection.namespace
      @fields = []
      @schema = {
        'bsonType' => 'object',
      }
    end

    def self.add(klass, encrypt_metadata: {})
      @@encrypted_models ||= {}

      model = self.new(klass)

      if encrypt_metadata.is_a?(Hash)
        model.schema['encryptMetadata'] = {}
        encrypt_metadata.each do |key, value|
          case key
          when :key_id
            if value.present?
              model.schema['encryptMetadata']['keyId'] = [{ '$uuid' => value }]
            end
          when :algorithm
            model.schema['encryptMetadata']['algorithm'] = value.presence || DEFAULT_ENCRYPT_ALGORITHM
          end
        end
      end
      @@encrypted_models[klass.name.to_s] = model
    end
  end
end
