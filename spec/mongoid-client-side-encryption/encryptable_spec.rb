# frozen_string_literal: true

require 'spec_helper'

describe MongoidClientSideEncryption::Encryptable do
  let!(:uuid) { "8a6cdd40-6d78-4fdb-912b-190e3057197f" }

  class MockData
    include Mongoid::Document
    include MongoidClientSideEncryption::Encryptable

    enable_mongodb_client_encryption encrypt_metadata: { key_id: "8a6cdd40-6d78-4fdb-912b-190e3057197f", algorithm: MongoidClientSideEncryption::Models::Field::ENCRYPT_ALGORITHM_RANDOM}

    field :some_data, type: Hash

    encrypts_field 'some_data.secret', type: String, encrypt: { algorithm: MongoidClientSideEncryption::Models::Field::ENCRYPT_ALGORITHM_RANDOM }
  end
  
  describe "#enable_mongodb_client_encryption" do
    it 'defines model level encryption options' do
      schema = MongoidClientSideEncryption::Model.encrypted_models['MockData'].schema
      expect(schema).to match({
        bsonType: 'object',
        encryptMetadata: {
          keyId: [:$uuid => uuid],
          algorithm: MongoidClientSideEncryption::Models::Field::ENCRYPT_ALGORITHM_RANDOM,
        },
      }.deep_stringify_keys)
    end
  end

  describe "#encrypts_field" do
    it 'defines the field with schema' do
      fields = MongoidClientSideEncryption::Model.encrypted_models['MockData'].fields
      schema = fields.find { |field| field.name == 'some_data.secret' }.schema
      expect(schema).to match({
        bsonType: 'string',
        algorithm: MongoidClientSideEncryption::Models::Field::ENCRYPT_ALGORITHM_RANDOM
      }.stringify_keys)
    end
  end
end
