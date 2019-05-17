class AddEncryptedKeyIvToDataEncryptionKeys < ActiveRecord::Migration
  def change
    add_column :data_encryption_keys, :encrypted_key_iv, :string, unique: true
  end
end
