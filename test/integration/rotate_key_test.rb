require 'test_helper'
require 'sidekiq/testing'





class RotateKeyFlowTest < ActionDispatch::IntegrationTest
  
  def setup 
    Sidekiq::Testing.inline! 
  end

  def teardown
    Sidekiq::Worker.clear_all
  end

  test "1K strings then rotate" do
    currkey = DataEncryptingKey.primary
    
    for i in  1..100  do  
      EncryptedString.create!(value: "Random string #{i}")
    end
 
    
    post "/data_encrypting_keys/rotate"
    assert_response :success

    sleep 3

    get "/data_encrypting_keys/rotate/status"
    assert_response :success

    assert_not_equal  currkey, DataEncryptingKey.primary
  end

  test "reconstruct long quote after rotation" do
    quote = <<-eos
          At the end of the day, you are solely responsible for your success and         
          your failure. And the sooner you realize that, you accept that, and integrate 
          that into your work ethic, you will start being successful. As long as you blame
           others for the reason you aren't where you want to be, you will always be a failure.
        eos

    wordarry = quote.gsub(/[^\w\s\d]/, '').split(" ")

    # we will resconstruct wordarray
    tokens = Array.new
    wordarry.each do |s|
      tokens << EncryptedString.create!(value: s).token
    end


    
    post "/data_encrypting_keys/rotate"
    assert_response :success

    sleep 3

    get "/data_encrypting_keys/rotate/status"
    assert_response :success


    decryptedstrings = Array.new
    tokens.each do |t|
      get encrypted_string_path(token: t)
      json = JSON.parse(response.body)
      decryptedstrings << json["value"]
    end

    assert_equal wordarry, decryptedstrings
    
    

  end
  

  


end


