require 'rails'
require 'active_support/all'
require 'mongoid_client_side_encryption/model'
require 'mongoid_client_side_encryption/schema_map'
require 'mongoid_client_side_encryption/encryptable'

if defined?(Rails)
  require "mongoid_client_side_encryption/railtie"
end

module MongoidClientSideEncryption
  mattr_accessor :auto_encryption_options

  def self.configure
    # TODO: Also support these options in this gem?
    @@auto_encryption_options = {
      key_vault_namespace: "#{ENV['MONGO_AUTO_ENCRYPTION_KEY_VAULT_DATABASE']}.#{ENV['MONGO_AUTO_ENCRYPTION_KEY_VAULT_NAMESPACE']}"
    }
    if ENV['MONGO_AUTO_ENCRYPTION_KMS_PROVIDER']
      provider = Kms::Provider.new.initialize_provider(ENV['MONGO_AUTO_ENCRYPTION_KMS_PROVIDER']).try(:to_options)
      @@auto_encryption_options[:kms_providers][ENV['MONGO_AUTO_ENCRYPTION_KMS_PROVIDER']] = provider
    end
  end

  def self.schema_map
    def self.bsonizer(arr, schema)
      if arr.length == 1
        {
          arr.shift => {
            encrypt: schema
          }
        }
      else
        {}.tap do |hash|
          hash[arr.shift] = {
            'bsonType' => 'object',
            'properties' => bsonizer(arr, schema),
          }
        end
      end
    end

    Model.encrypted_models.reduce({}) do |obj, (_, model)|
      obj[model.namespace] = model.schema.merge(
        Hash.new.tap do |schema|
          schema[:properties] = model.fields.reduce({}) do |props, field|
            namespaced_field_name = field.encrypted_field_name.to_s.split('.')
            if namespaced_field_name.length > 1
              result = bsonizer(namespaced_field_name, field.schema)
              props.deep_merge!(result)
            else
              props[field.encrypted_field_name] = {
                encrypt: field.schema,
              }
            end

            props
          end
        end
      )

      obj
    end
  end
end
