require 'test_helper'

class DataEncryptingKeyTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end

  test ".generate! creates at least one more record" do
    assert_difference "DataEncryptingKey.count" do
      key = DataEncryptingKey.generate!
      assert key
    end
  end

  test ".generate! creates a distinct record after 100 tries" do
    oldkey = Object
    for i in 1..100 do
      # make new key primary key
      DataEncryptingKey.primary.update_attributes(primary: false)
      oldkey = DataEncryptingKey.generate!(primary: true)
    end

     
    assert (DataEncryptingKey.where("encrypted_key = ?", oldkey.encrypted_key).count == 1)
    
  end


  test "rotate_key reencrypts a String..we want to get same plaintext back" do
    old_key_id = DataEncryptingKey.primary.id
    encrypted_string1 = EncryptedString.create!(value: "Test string for rotate 1")
    encrypted_string2 = EncryptedString.create!(value: "Test string for rotate 2")
    token1 = encrypted_string1.token
    token2 = encrypted_string2.token

    # Call the rotate function
    DataEncryptingKey.rotate_key

    new_key = DataEncryptingKey.primary
    assert_not_equal old_key_id, new_key.id

    
    encrypted_string = EncryptedString.find_by(token: token1)
    # make sure the data encrypting key is the new one
    assert_equal new_key.id, encrypted_string.data_encrypting_key.id
   
    assert_equal "Test string for rotate 1", encrypted_string.value
    assert_equal 0, DataEncryptingKey.where(id: old_key_id).count
  end



end
