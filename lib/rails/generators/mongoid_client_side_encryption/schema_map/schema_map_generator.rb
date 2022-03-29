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
      schema_map = Model.encrypted_models.reduce({}) do |obj, (_, model)|
        obj[model.namespace] = model.schema.merge({
          properties: model.fields.reduce({}) do |props, field|
            props[field.encrypted_field_name] = {
              encrypt: field.schema,
            }
            props
          end
        })
        obj
      end
      create_file "config/mongodb_schema_map.json", schema_map.to_json
    end

  end
end
