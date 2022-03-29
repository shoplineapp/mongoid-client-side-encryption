module MongoidClientSideEncryption
  module Kms
    module Providers
      class Aws
        def initializer
          @access_key_id = ENV['MONGO_AUTO_ENCRYPTION_AWS_KMS_ACCESS_KEY_ID']
          @secret_access_key = ENV['MONGO_AUTO_ENCRYPTION_AWS_KMS_SECRET_ACCESS_KEY']
        end

        def to_options
          {
            access_key_id: @access_key_id,
            secret_access_key: @secret_access_key,
          }
        end
      end
    end
  end
end
