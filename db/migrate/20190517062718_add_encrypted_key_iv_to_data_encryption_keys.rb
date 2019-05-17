class AddEncryptedKeyIvToDataEncryptionKeys < ActiveRecord::Migration
  def change
    add_column :data_encrypting_keys, :encrypted_key_iv, :string, unique: true
  end
end
