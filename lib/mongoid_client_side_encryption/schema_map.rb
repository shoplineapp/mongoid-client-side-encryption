# frozen_string_literal: true

require 'bson'

module MongoidClientSideEncryption
  class SchemaMap
    attr_reader :data, :initialized

    def initialize(data)
      @initialized = false
      @data = data
    end

    # Proxy all method to data hash
    def method_missing(m, *args, &block)
      lazy_initialize!
      @data.send(m, *args, &block)
    end

    # Convert raw JSON string to a hash
    def lazy_initialize!
      return if @initialized
      @data = @data.to_json if @data.is_a?(Hash)
      @data = BSON::ExtJSON.parse(@data)
    rescue JSON::ParserError, ::BSON::Error::ExtJSONParseError
      @data = {}
    ensure
      @initialized = true
    end

    # Hackaround for Mongo::Crypt::Handle to use this class as Hash
    def is_a?(klass)
      @data.is_a?(klass)
    end

    def to_hash
      lazy_initialize!
      @data
    end
  end
end
