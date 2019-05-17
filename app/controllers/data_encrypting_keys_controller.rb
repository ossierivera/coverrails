class DataEncryptingKeysController < ApplicationController
  def rotate
    if RotateKeyJobs.add_new?
      RotateWorker.perform_async('rotate')
      render json: { message: "Successfully queued job for key rotation at #{DateTime.now}" }
    else
      render json: { message: "Cannot schedule a new key rotation at "\
                              "this time due to a previous scheduled "\
                              "rotation. Current status of Queue: "\
                              "#{RotateKeyJobs.get_status_message}" },
             status: :conflict
    end
  end

  def status
    render json: { message: RotateKeyJobs.get_status_message }    
  end
end


class RotateWorker
  include Sidekiq::Worker

  sidekiq_options retry:false

  def perform(param)
    puts "Started Sidekiq RotateKeys task."
    DataEncryptingKey.rotate_key

    puts "Completed RotateKeys job."
  end
end
