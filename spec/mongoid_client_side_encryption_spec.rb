# frozen_string_literal: true

require 'spec_helper'

describe MongoidClientSideEncryption do
  describe '.schema_map' do
    let(:key_id) { '4d105a31-15d4-4fb1-ad9e-1689a02fc1f0' }
    let(:algorithm) { 'AEAD_AES_256_CBC_HMAC_SHA_512-Random' }

    let!(:klass) do
      class MockModel
        include Mongoid::Document
        include MongoidClientSideEncryption::Encryptable
   
        enable_mongodb_client_encryption encrypt_metadata: { key_id: '4d105a31-15d4-4fb1-ad9e-1689a02fc1f0', algorithm: 'AEAD_AES_256_CBC_HMAC_SHA_512-Random' }
  
        field :email, type: String, encrypt: true
        field :some_data, type: Hash

        encrypts_field 'some_data.id', type: Integer, encrypt: true
        encrypts_field 'some_data.config.secret', type: String, encrypt: true
      end
    end

    subject { MongoidClientSideEncryption.schema_map.deep_stringify_keys }

    it 'renders a schema map based on registered model and field schema' do
      is_expected.to match({
        'shopline_test.mock_models' => {
          'bsonType' => 'object',
          'encryptMetadata' => {
            'keyId' => ['$uuid' => key_id],
            'algorithm' => algorithm,
          },
          'properties' => {
            'encrypted_email' => {
              'encrypt' => {
                'bsonType' => 'string',
                'algorithm' => MongoidClientSideEncryption::Models::Field::DEFAULT_ENCRYPT_ALGORITHM,
              }
            },
            'some_data' => {
              'bsonType' => 'object',
              'properties' => {
                'id' => {
                  'encrypt' => {
                    'bsonType' => 'double',
                    'algorithm' => MongoidClientSideEncryption::Models::Field::DEFAULT_ENCRYPT_ALGORITHM,
                  }
                },
                'config' => {
                  'bsonType' => 'object',
                  'properties' => {
                    'secret' => {
                      'encrypt' => {
                        'bsonType' => 'string',
                        'algorithm' => MongoidClientSideEncryption::Models::Field::DEFAULT_ENCRYPT_ALGORITHM,
                      }
                    }
                  }
                }
              }
            }
          }
        }
      })
    end
  end
end
