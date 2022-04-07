# frozen_string_literal: true

require 'rails/generators/base'

module MongoidClientSideEncryption
  class SchemaMapGenerator < Rails::Generators::Base
    desc "Creates a Mongodb schema map configuration file at config/mongodb_schema_map.json"

    def self.source_root
      File.expand_path("./templates", __dir__)
    end

    def create_schema_map_file
      # Rendering YML with ERB cannot preseve the indentation
      # Force schema map to formatted JSON string
      schema_map = MongoidClientSideEncryption.schema_map
      create_file "config/mongodb_schema_map.json", schema_map.to_json
    end

  end
end
