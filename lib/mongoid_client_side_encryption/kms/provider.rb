module MongoidClientSideEncryption
  module Kms
    module Provider
      def initialize_provider(type)
        return "#{type.camelize}".constantize.new
      rescue NameError
        Rails.logger.error "Unable to load #{type} KMS provider"
        return nil
      end
    end
  end
end
