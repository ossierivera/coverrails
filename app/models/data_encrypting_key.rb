class DataEncryptingKey < ActiveRecord::Base
  has_many :encrypted_strings

  attr_encrypted :key,
                 mode: :per_attribute_iv,
                 key: :key_encrypting_key
                 #algorithm: 'aes-256-cfb'

  validates :key, presence: true

  
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

  def self.rotate_key
    # this must lock the database because we don't want any race conditions here
    DataEncryptingKey.transaction do
      DataEncryptingKey.primary.update!(primary: false)
      DataEncryptingKey.generate!(primary: true)
    end
    
    EncryptedString.all.each do |es|
      es.reencrypt!(DataEncryptingKey.primary)
    end

    DataEncryptingKey.where(primary: false).destroy_all 
    
  end
  
  def key_encrypting_key
    ENV['KEY_ENCRYPTING_KEY']
  end
end

