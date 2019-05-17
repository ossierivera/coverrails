require 'sidekiq/api'

class DataEncryptingKeysController < ApplicationController
  def rotate
    begin 
      RotateWorker.perform_async()
    rescue SidekiqUniqueJobs::Conflict
      render json: { message: "A job has already been scheduled. Cannot run another one at this time" },
             status: :conflict
    else
      render json: { message: "Job created successfully" }, status: :ok
    end
  end

  def status
    render json: { message: RotateKeyJobs.get_status_message }    
  end
end


class RotateWorker
  include Sidekiq::Worker

  sidekiq_options retry:false

  def perform()
    DataEncryptingKey.rotate_key
  end
end
