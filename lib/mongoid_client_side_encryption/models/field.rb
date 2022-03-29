# frozen_string_literal: true

module MongoidClientSideEncryption
  module Models
    class Field
      TYPE_MAPPINGS = ::Mongoid::Fields::TYPE_MAPPINGS.invert.freeze
      DEFAULT_ENCRYPT_ALGORITHM = 'AEAD_AES_256_CBC_HMAC_SHA_512-Deterministic'.freeze

      attr_reader :name, :encrypted_field_name, :schema

      def initialize(klass, field, options = {})
        @name = klass.database_field_name(field.name)
        @encrypted_field_name = :"encrypted_#{field.name}"
        @schema = {
          'bsonType' => TYPE_MAPPINGS[field.type],
          'algorithm' => options.fetch(:algorithm, DEFAULT_ENCRYPT_ALGORITHM),
        }
        if options.fetch(:key_id, nil).present?
          @schema['keyId'] = [{ '$uuid' => options.fetch(:key_id) }]
        end
      end

      def self.add(klass, field, options)
        if Model.encrypted_models[klass.name].present?
          model_field = self.new(klass, field, options)
          Model.encrypted_models[klass.name].fields << model_field

          # Dynamic concern for field override
          m = Module.new do
            extend ActiveSupport::Concern

            included do |base|
              # Add constant for raw mongo query usage
              # e.g.
              # Model.collection.bulk_write([
              #  { update_one: { filter: { _id: id }, update: { :'$set' => { Model::FIELD_SECRET: secret }} } }
              # ])
              const_set :"FIELD_#{field.name.upcase}", (options[:migrating] ? field.name : model_field.encrypted_field_name).to_s.freeze

              # New field for encrypted data
              send(:field, model_field.encrypted_field_name, (klass.fields[field.name].options || {}).except(:encrypt, :klass))

              # Override getter
              alias_method :"shadow_read_#{field.name}", :"#{field.name}"
              define_method "#{field.name}" do
                val = send(:"encrypted_#{field.name}")
                if val.nil? && options[:migrating] == true
                  val = send(:"shadow_read_#{field.name}")
                end
                val
              end

              # Override setter to double write values
              alias_method :"shadow_write_#{field.name}", :"#{field.name}="
              define_method "#{field.name}=" do |val|
                send(:"#{model_field.encrypted_field_name}=", val)
                if options[:migrating] == true
                  send(:"shadow_write_#{field.name}", val)
                end
              end
            end
          end
          unless klass.include m
            Rails.logger.error "Unable to include encrypted field #{field.name}"
          end
        end
      end
    end
  end
end
