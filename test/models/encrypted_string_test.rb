require 'test_helper'

class EncryptedStringTest < ActiveSupport::TestCase

  setup do
    @key = DataEncryptingKey.generate!(primary: true)
    @encrypted_string = EncryptedString.create(value: 'test_case')
  end

  teardown do
    @encrypted_string.destroy!
    @key.destroy!
  end

  test "check decryption" do
    assert_equal(@encrypted_string.value, "test_case")
  end

  test "create" do
    assert @encrypted_string.token
    assert @encrypted_string.data_encrypting_key_id
  end

  test "used the appropriate encryption key" do
    assert_equal @encrypted_string.data_encrypting_key_id,  @key.id
  end
  
end
