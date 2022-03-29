# Mongoid Client-Side Encryption

Mongodb provides a great framework for clients to encrypt fields in documents ([Client-side Encryption](https://www.mongodb.com/docs/manual/core/security-client-side-encryption/)). However, the official support is only on driver level ([Mongo Ruby Driver](https://docs.mongodb.com/ruby-driver/current/reference/client-side-encryption/)) and lack of support on Mongoid ([Ticket](https://jira.mongodb.org/browse/MONGOID-5007)).  

This gem is an extension on Mongoid for enhancing the developer experience on the usage of client-side encryption. It provides the following features:
- Works with Mongoid fields
  - Configure encryption along with model field definition
- Generate schema map Mongodb needed
  - A generator to extra encryption config and return the schema map in JSON format.
- Makes migrating existing data easy
  - Double-write existing and encrypted fields for safe-migration (value will be saved into original field and an encrypted field simultaneously)

Remarks:  
> Since Mongoid with Rails are strictly working with mongoid.yml, there is an issue that mongo-ruby-driver expects the data keys of schema map in BSON::Binary format and there is no way to work the YAML file.  
We changed the crypt handler in mongo-ruby-driver and add extra `BSON::ExtJSON.parse` step before setting up the schema map. You might reference to this [patched branch](https://github.com/shoplineapp/mongo-ruby-driver/tree/feature/mongo-crypt-schema-map-init) instead.


## Installation

Add the gem into the `Gemfile`

```ruby
gem 'mongoid-client-side-encryption', git: 'https://github.com/shoplineapp/mongoid-client-side-encryption'
```

## Configuration

First, follow the official documentation to install `libmongocrypt` and `mongocryptd`.

And then go to your model and update fields you need to encrypt, for example if you want to encrypt the email of the User model. 
- Include the `MongoidClientSideEncryption::Encryptable` concern provided
- Run `enable_mongodb_client_encryption` to register model (optionally you might set `encrypt_metadata` along with the config)
- Add extra option `encrypt` with desired field settings


```ruby
class User
  include Mongoid::Document
  include MongoidClientSideEncryption::Encryptable

  enable_mongodb_client_encryption encrypt_metadata: { key_id: 'a0f76259-b314-48f0-a829-dbcc7027328b' }

  field :email, type: String, encrypt: {
    migrating: true,
    algorithm: 'AEAD_AES_256_CBC_HMAC_SHA_512-Deterministic',
    key_id: 'bdf8a4b0-9e29-44eb-9c4d-f66391ff731f'
  }
end
```

After the model configuration, when you operate with the `email` field, it will try to update the `email` and also a `encrypted_email` field as well. To enable the client-side encryption provided by Mongodb framework, you should setup the `auto_encryption_options` in `mongoid.yml`.  
  
Before that, let's generate the schema map based on the model definition we set in the previous step by running the following generator:

```bash
rails generate mongoid_client_side_encryption:schema_map
```

The output file will be generated to `config/mongodb_schema_map.json`

Sample

```json
{
  "shopline.users": {
    "bsonType": "object",
    "encryptMetadata": {
      "keyId": [
        {
          "$uuid": "2ffe54ab-2b04-4556-80ca-7f96e709b2b6"
        }
      ]
    },
    "properties": {
      "mobile_phone": {
        "encrypt": {
          "bsonType": "string",
          "algorithm": "AEAD_AES_256_CBC_HMAC_SHA_512-Deterministic"
        }
      },
      "email": {
        "encrypt": {
          "bsonType": "string",
          "algorithm": "AEAD_AES_256_CBC_HMAC_SHA_512-Deterministic"
        }
      }
    }
  }
}
```

### Usage

Add the generated schema map along with the `auto_encryption_options` in `config/mongoid.yml`

```yml
clients:
  default:
    ...
    options:
      auto_encryption_options:
        key_vault_namespace: ...
        kms_providers: ...
        schema_map: <%= File.read('config/mongodb_schema_map.json') %>
    ...
```

We are all set and ready to start the application.

### Options

Lists the supported parameters of the `enable_mongodb_client_encryption` model registeration call  
  
| Parameter | Description | Default |
| ------------------------------- | ------------------------------------------------------------------------------- | --------------------------------------------|
| `encrypt_metadata`                      | Extra encrypt metadata needed for client-side encryption ([Doc](https://www.mongodb.com/docs/manual/reference/security-client-side-automatic-json-schema/#encryptmetadata-schema-keyword))                                                                   | `{}`                                        |
| `encrypt_metadata.algorithm` | The encryption algorithm to use to encrypt a given field.<br><br>Supported Supports:<br>`AEAD_AES_256_CBC_HMAC_SHA_512-Random`<br>`AEAD_AES_256_CBC_HMAC_SHA_512-Deterministic` | `AEAD_AES_256_CBC_HMAC_SHA_512-Deterministic` |
| `encrypt_metadata.key_id` | The UUID of the model level data encryption key | `nil` |

Lists the supported parameters of the `encrypt` option in field definition  
  
| Parameter | Description | Default |
| ------------------------------- | ------------------------------------------------------------------------------- | --------------------------------------------|
| `migrating` | When this is `true`, the gem will try to double-write data into encrypted and unencrypted field, and `FIELD_XXX` constant will return the unencrypted field as well.<br><br>Expects application to migrate and encrypt data into encrypted field and then switch this config to `false` | `false` |
| `algorithm` | The encryption algorithm to use to encrypt a given field.<br><br>Supported Supports:<br>`AEAD_AES_256_CBC_HMAC_SHA_512-Random`<br>`AEAD_AES_256_CBC_HMAC_SHA_512-Deterministic` | `AEAD_AES_256_CBC_HMAC_SHA_512-Deterministic` |
| `key_id` | The UUID of the field level data encryption key | `nil` |

## Demo

### Working with Model

```ruby
> user = User.create!(email: 'philip+git@shoplineapp.com'); nil
> user.email
=> "philip@shoplineapp.com"
> PP.pp user.attributes
=> {
  "_id"=>BSON::ObjectId('6242ce1169537f02dd6274ee'),
  "encrypted_email"=>"philip@shoplineapp.com",
  "email"=>"philip@shoplineapp.com"
}}
> user.reload; nil
> user.email = "philip+changed@shoplineapp.com"
=> "philip+changed@shoplineapp.com"
> user.changes
=> {"encrypted_email"=>["philip@shoplineapp.com", "philip+changed@shoplineapp.com"], "email"=>["philip@shoplineapp.com", "philip+changed@shoplineapp.com"]}
```

If you check the raw data in Mongodb, you will see the `email` (unencrypted) and a `encrypted_email` (encrypted with client-side encryption)

```json
{
  "_id": {
    "$oid": "6242b23869537f02dd6274ec"
  },
  "encrypted_email": {
    "$binary": "AS/+VKsrBEVWgMp/lucJsrYCvfp9pqvkS27rY3QamZOeuyRm/GuoruAiWV09NEytWIfB8zDwLRSrMSABSn8FbQBUSxNJAAKhB7e6kx9Q5xHvAvcW4inVj2rd5lXwXTte8Tw=",
    "$type": "6"
  },
  "email": "philip+changed@shoplineapp.com",
  "updated_at": {
    "$date": "2022-03-29T07:16:08.058Z"
  },
  "created_at": {
    "$date": "2022-03-29T07:16:08.058Z"
  }
}
```

### Working with bulk or raw mongodb query

If you need to work without the model like performing bulkwrite or query, you might use the `FIELD_` constant to select the correct field during migration period.

```ruby
Model.collection.bulk_write([
  {
    update_one: {
      filter: {
        _id: id
      },
      update: {
        :'$set' => {
          Model::FIELD_SECRET: secret
        }
      }
    }
  }
])
```

## Known issues

There are some limitations with this gem:
- It does not work with deeply nested embedded field on schema map

## License

[MIT](LICENSE)
