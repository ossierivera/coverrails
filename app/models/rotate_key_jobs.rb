class RotateKeyJobs
  JOB_STATUS = {:empty => "No key rotation queued or in progress",
            :queued => "Key rotation has been queued",
            :in_progress => "Key rotation is in progress"
           }

  #Because the app is best used as a microservice, there should be no other app
  #sharing the job queue and worker pool that is why these functions are so simple
  def self.queued?
    Sidekiq::Queue.new.size
  end

  
  def self.busy?
    Sidekiq::Workers.new.size
  end


  def self.get_status_message
    message = if RotateKeyJobs.queued? 
      JOB_STATUS[:queued] 
    elsif RotateKeyJobs.busy?
      JOB_STATUS[:in_progress] 
    else
      JOB_STATUS[:empty]
    end
  end

end
