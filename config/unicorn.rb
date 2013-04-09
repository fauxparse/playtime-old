worker_processes 3
timeout 30
preload_app true

@resque_pid = nil

before_fork do |server, worker|
  @resque_pid ||= spawn("bundle exec rake resque:work QUEUE=*")
  
  Signal.trap 'TERM' do
    puts 'Unicorn master intercepting TERM and sending myself QUIT instead'
    Process.kill 'QUIT', Process.pid
    Process.kill 'TERM', @resque_pid if @resque_pid
  end

  if defined?(Resque)
    Resque.redis.quit
    Rails.logger.info('Disconnected from Redis')
  end
  
  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.connection.disconnect!
end

after_fork do |server, worker|

  Signal.trap 'TERM' do
    puts 'Unicorn worker intercepting TERM and doing nothing. Wait for master to send QUIT'
  end
  
  if defined?(Resque)
    Resque.redis = ENV['REDISCLOUD_URL'] or "redis://localhost:6379"
    Rails.logger.info('Connected to Redis')
  end

  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.establish_connection
end