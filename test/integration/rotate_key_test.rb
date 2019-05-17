require 'test_helper'
require 'sidekiq/testing'

def setup 
   Sidekiq::Testing.inline! 
end

class RotateKeyFlowTest < ActionDispatch::IntegrationTest
  old_key = DataEncryptingKey.primary
  test "rotate" do
    (1..1000).each do |i|
      EncryptedString.create!(value: "Test string integration #{i}")
    end	
    post "/data_encrypting_keys/rotate"
    assert EncryptedString.all.count >= 1000
    assert_response :success
    assert_not_equal old_key.id, DataEncryptingKey.primary.id
  end
end
