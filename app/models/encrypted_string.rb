class EncryptedString < ActiveRecord::Base
  belongs_to :data_encrypting_key

  attr_encrypted :value,
                 mode: :per_attribute_iv,
                 key: :encrypted_encryption_key
                 #algorithm: 'aes-256-cfb'
  
  
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

  def reencrypt!(new_key)
    self.update_attributes(data_encrypting_key_id: new_key.id,
            value: value)
  end

  private

  def set_token
    begin
      self.token = SecureRandom.urlsafe_base64
    end while EncryptedString.where(token: self.token).present?
  end

  def set_data_encrypting_key
    self.data_encrypting_key ||= DataEncryptingKey.primary
  end
end
