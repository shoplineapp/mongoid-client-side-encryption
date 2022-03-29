require 'active_support/all'
require 'mongoid_client_side_encryption/model'
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
end
