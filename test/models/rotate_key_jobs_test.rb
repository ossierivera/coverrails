require 'test_helper'
require 'sidekiq/testing'

class DataEncryptingKeyTest < ActiveSupport::TestCase
  def setup
    Sidekiq::Testing.fake!
  end

  test "add_new?" do
    if RotateKeyJobs.queued_jobs > 0 or 
      RotateKeyJobs.busy_jobs > 0
      assert_equal false, RotateKeyJobs.add_new?
    else
      assert_equal true, RotateKeyJobs.add_new?
    end
  end
end
