class RotateKeyWorker
  include Sidekiq::Worker

  # Set sidekiq retry false since we do not want
  # automatic retry for now.
  sidekiq_options retry:false

  def perform(param)
    puts "Started Sidekiq RotateKeys task."
    DataEncryptingKey.rotate_key

    puts "Completed RotateKeys job."
  end
end
