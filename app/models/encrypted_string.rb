class EncryptedString < ActiveRecord::Base
  belongs_to :data_encrypting_key

  attr_encrypted :value,
                 mode: :per_attribute_iv_and_salt,
                 key: :encrypted_encryption_key

  validates :token, presence: true, uniqueness: true
  validates :data_encrypting_key, presence: true
  validates :value, presence: true

  before_validation(on: :create) do
    set_token 
    set_data_encrypting_key
  end

  def encrypted_encryption_key
    self.data_encrypting_key ||= DataEncryptingKey.primary
    data_encrypting_key.encrypted_key
  end

  # Use find_each since it does batch processing 
  # for 1000 records. Gets all the records that 
  # are not using the new key and recrypts them all.
  def self.re_encrypt_all(new_key)
    EncryptedString.where("data_encrypting_key_id != ?", new_key.id)
                   .find_each do |encrypted_string|
      encrypted_string.reencrypt!(new_key)
    end
  end

  # Updates the key with the new key and passes
  # the unencrypted value to the update method
  # so that the value gets encrypted with the new 
  # key.
  def reencrypt!(new_key)
    update!(data_encrypting_key_id: new_key.id,
            value: value)
  end

  private

  def encryption_key
    self.data_encrypting_key ||= DataEncryptingKey.primary
    data_encrypting_key.key
  end

  def set_token
    begin
      self.token = SecureRandom.hex
    end while EncryptedString.where(token: self.token).present?
  end

  def set_data_encrypting_key
    self.data_encrypting_key ||= DataEncryptingKey.primary
  end
end
