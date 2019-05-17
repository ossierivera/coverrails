class RotateKeyJobs
  ROTATE_STATUS = {
    EMPTY: "No key rotation queued or in progress",
    QUEUED: "Key rotation has been queued",
    IN_PROGRESS: "Key rotation is in progress"
  }

  # Return the number of jobs that are enqueued
  # in the default sidekiq queue
  def self.queued_jobs
    Sidekiq::Queue.new.size
  end

  # Return the number of busy jobs in sidekiq
  def self.busy_jobs
    ps = Sidekiq::ProcessSet.new
    busy_count = 0
    ps.each do |process|
      busy_count += process['busy']   
    end
    busy_count
  end

  # Returns true if it is ok to add new job
  def self.add_new?
    self.queued_jobs == 0 && self.busy_jobs == 0
  end

  def self.get_status_message
    message = if RotateKeyJobs.queued_jobs > 0 
      ROTATE_STATUS[:QUEUED] 
    elsif RotateKeyJobs.busy_jobs > 0
      ROTATE_STATUS[:IN_PROGRESS] 
    else
      ROTATE_STATUS[:EMPTY]
    end
  end

end
