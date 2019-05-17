require 'test_helper'

class DataEncryptingKeyTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end

  test ".generate!" do
    assert_difference "DataEncryptingKey.count" do
      key = DataEncryptingKey.generate!
      assert key
    end
  end

  test "primary" do
    key = DataEncryptingKey.primary
    assert key
  end

  test "generate_new_primary" do 
  	key = DataEncryptingKey.primary
    DataEncryptingKey.generate_new_primary
    # make sure that the old primary has primary false
    assert_equal false, DataEncryptingKey.find(key.id).primary
    # make sure the last key has the primary true (new primary)
    assert_equal true, DataEncryptingKey.last.primary
    # make sure the id of old and new primary keys is different
    assert_not_equal key.id, DataEncryptingKey.primary.id
  end

  test "rotate_key" do
    old_key_id = DataEncryptingKey.primary.id

    # Create 2 encrypted strings
    encrypted_string1 = EncryptedString.create!(value: "Test string for rotate 1")
    encrypted_string2 = EncryptedString.create!(value: "Test string for rotate 2")
    token1 = encrypted_string1.token
    token2 = encrypted_string2.token

    # Call the rotate function
    DataEncryptingKey.rotate_key

    # Make sure that the Data Encrypting key changed
    new_key = DataEncryptingKey.primary
    assert_not_equal old_key_id, new_key.id

    # Get the string 1
    encrypted_string = EncryptedString.find_by(token: token1)
    # make sure the data encrypting key is the new one
    assert_equal new_key.id, encrypted_string.data_encrypting_key.id
    # make sure the original string can be retrieved.
    assert_equal "Test string for rotate 1", encrypted_string.value

    # Get the string 2
    encrypted_string = EncryptedString.find_by(token: token2)
    # make sure the data encrypting key is the new one
    assert_equal new_key.id, encrypted_string.data_encrypting_key.id
    # make sure the original string can be retrieved.
    assert_equal "Test string for rotate 2", encrypted_string.value

    # Make sure the old unused keys are deleted
    assert_equal 0, DataEncryptingKey.where(id: old_key_id).count
  end
end
