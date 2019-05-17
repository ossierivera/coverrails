require 'test_helper'
require 'sidekiq/testing'

class DataEncryptingKeysControllerTest < ActionController::TestCase

  def setup
    Sidekiq::Testing.fake!
    @data_encrypting_key = DataEncryptingKey.generate!(primary: true)
  end

  test "POST #rotate return success when queue empty" do
    Sidekiq::Worker.clear_all
    post :rotate

    assert_response :success

    json = JSON.parse(response.body)
    assert json["message"].include?("Job created successfully")
  end

  test "GET #status " do
    get :status

    assert_response :success
    json = JSON.parse(response.body)
    assert json["message"].include?("rotation")
  end
end
