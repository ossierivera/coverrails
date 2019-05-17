require 'test_helper'
require 'sidekiq/testing'

class DataEncryptingKeysControllerTest < ActionController::TestCase

  def setup
    Sidekiq::Testing.fake!
    @data_encrypting_key = DataEncryptingKey.generate!(primary: true)
  end

  test "post rotate there should not exist another DataEncryption key " do
    Sidekiq::Worker.clear_all
    post :rotate
    for i in 1..100 do
      EncryptedString.create!(value: "#{i} in line")
    end

    post :rotate

    #there better be 100 records with the exact same encrypted key
    assert EncryptedString.where("data_encrypting_key_id != ?", @data_encrypting_key.id).count == 0
    
    
  end

  test "GET #status " do
    get :status

    assert_response :success
    json = JSON.parse(response.body)
    assert json["message"].include?("rotation")
  end
end
