# frozen_string_literal: true

require 'spec_helper'

describe MongoidClientSideEncryption::Models::Field do
  class MockUser
    include Mongoid::Document
    include MongoidClientSideEncryption::Encryptable

    field :email, type: String, encrypt: true
    field :private_email, type: String, encrypt: { algorithm: MongoidClientSideEncryption::Models::Field::ENCRYPT_ALGORITHM_RANDOM }
    field :phone, type: String, encrypt: { migrating: true }
    field :some_data, type: Hash, encrypt: true
    field :some_items, type: Array, encrypt: true
    field :agreement, type: Boolean, encrypt: true
    field :balance, type: Integer, encrypt: true
    field :precise_balance, type: Float, encrypt: true
  end

  context 'when the model is using encrypt option' do
    it 'defines getter/setter on encrypted field' do
      object = MockUser.new
      object.email = Faker::Internet.email
      expect(object.attributes.keys).to match_array(['_id', 'encrypted_email'])
      expect(object.attributes['encrypted_email']).to eq object.email
    end

    it 'defines constant for raw mongo query' do
      expect(MockUser.const_get('FIELD_EMAIL')).to eq 'encrypted_email'
    end

    it 'defines schema of field' do
      fields = MongoidClientSideEncryption::Model.encrypted_models['MockUser'].fields
      {
        email: { bsonType: 'string', algorithm: MongoidClientSideEncryption::Models::Field::ENCRYPT_ALGORITHM_DETERMINISTIC },
        private_email: { bsonType: 'string', algorithm: MongoidClientSideEncryption::Models::Field::ENCRYPT_ALGORITHM_RANDOM },
        phone: { bsonType: 'string', algorithm: MongoidClientSideEncryption::Models::Field::ENCRYPT_ALGORITHM_DETERMINISTIC },
        some_data: { bsonType: 'object', algorithm: MongoidClientSideEncryption::Models::Field::ENCRYPT_ALGORITHM_RANDOM },
        some_items: { bsonType: 'array', algorithm: MongoidClientSideEncryption::Models::Field::ENCRYPT_ALGORITHM_RANDOM },
        phone: { bsonType: 'string', algorithm: MongoidClientSideEncryption::Models::Field::ENCRYPT_ALGORITHM_DETERMINISTIC },
        agreement: { bsonType: 'bool', algorithm: MongoidClientSideEncryption::Models::Field::ENCRYPT_ALGORITHM_DETERMINISTIC },
        balance: { bsonType: 'double', algorithm: MongoidClientSideEncryption::Models::Field::ENCRYPT_ALGORITHM_DETERMINISTIC },
        precise_balance: { bsonType: 'decimal128', algorithm: MongoidClientSideEncryption::Models::Field::ENCRYPT_ALGORITHM_DETERMINISTIC },
      }.deep_stringify_keys.each do |name, schema|
        expect(fields.find { |field| field.name == name }.schema).to match(schema)
      end
    end

    context 'when algorithm is given' do
      subject(:fields) { MongoidClientSideEncryption::Model.encrypted_models['MockUser'].fields }
      it 'sets into schema' do
        expect(fields.find { |field| field.name == 'private_email' }.schema['algorithm']).to eq MongoidClientSideEncryption::Models::Field::ENCRYPT_ALGORITHM_RANDOM
      end
    end

    context 'when field is array or hash' do
      subject(:fields) { MongoidClientSideEncryption::Model.encrypted_models['MockUser'].fields }
      it 'forces the encryption algorithm to random' do
        %w[some_data some_items].each do |name|
          expect(fields.find { |field| field.name == name }.schema['algorithm']).to eq MongoidClientSideEncryption::Models::Field::ENCRYPT_ALGORITHM_RANDOM
        end
      end
    end
  end

  context 'when the field in migrating mode' do
    let(:original_phone) { Faker::PhoneNumber.phone_number }
    let(:encrypted_phone) { Faker::PhoneNumber.phone_number }

    it 'double-writes data into original and encrypted fields' do
      object = MockUser.new
      object.phone = Faker::PhoneNumber.phone_number
      expect(object.attributes.keys).to match_array(['_id', 'phone', 'encrypted_phone'])
      expect(object.attributes['phone']).to eq object.phone
      expect(object.attributes['encrypted_phone']).to eq object.phone
    end

    it 'defines constant for raw mongo query' do
      expect(MockUser.const_get('FIELD_PHONE')).to eq 'phone'
    end

    context 'and encrypted field has value' do
      it 'reads data from encrypted field and then original field' do
        object = MockUser.new phone: original_phone, encrypted_phone: encrypted_phone
        expect(object.phone).to eq encrypted_phone
  
        object.assign_attributes encrypted_phone: nil
        expect(object.phone).to eq original_phone
      end
    end

    context 'and encrypted field is empty' do
      it 'reads data from original field' do
        object = MockUser.new phone: original_phone
        expect(object.phone).to eq original_phone
      end
    end
  end
end
