class DataEncryptingKey < ActiveRecord::Base
  has_many :encrypted_strings

  attr_encrypted :key,
                 mode: :per_attribute_iv,
                 key: :key_encrypting_key,
                 algorithm: 'aes-256-cfb'

  validates :key, presence: true

  # Generate the primary key if no primary key is
  # present (usually while running app for first time) 
  # else return the current primary:true key
  def self.primary
    primary_key = find_by(primary: true)
    if primary_key.nil?
      primary_key = DataEncryptingKey.generate!(primary: true)
    end
    primary_key
  end

  def self.generate!(attrs={})
    create!(attrs.merge(key: AES.key))
  end

  # Updates the old primary key as primary: false
  # and generates a new primary key.
  def self.generate_new_primary
    DataEncryptingKey.transaction do
      DataEncryptingKey.primary.update!(primary: false)
      DataEncryptingKey.generate!(primary: true)
    end
  end

  # Deletes all the non primary keys which are
  # not used in any Encrypted Strings
  def self.delete_unused_keys
    DataEncryptingKey.where(primary: false).each do |d_key|
      if EncryptedString.where(data_encrypting_key_id: d_key.id).count == 0
        d_key.delete
      end
    end
  end

  def self.rotate_key
    # Generate a new primary key and mark old key
    # as primary: false
    DataEncryptingKey.generate_new_primary

    # For each encrypted string not using current 
    # primary key, decrypt the string and encrypt 
    # using new primary key
    EncryptedString.re_encrypt_all(DataEncryptingKey.primary)

    # Delete any unused primary: false keys
    DataEncryptingKey.delete_unused_keys
  end
  
  def key_encrypting_key
    ENV['KEY_ENCRYPTING_KEY']
  end
end

