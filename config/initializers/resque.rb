ENV["REDISCLOUD_URL"] ||= "redis://localhost:6379/"
uri = URI.parse(ENV["REDISCLOUD_URL"])
Resque.redis = Redis.new(host: uri.host, port: uri.port, password: uri.password)
Dir["#{Rails.root}/app/jobs/*.rb"].each { |file| require file }

module Resque
  extend self
  
  def pop_with_readiness(queue)
    if job = peek(queue)
      key = delay_key job["class"], *job["args"]
      time = redis.get key
      unless (time = redis.get(key)) and (DateTime.parse(time) > DateTime.now)
        return pop_without_readiness(queue)
      end
    end
  end
  alias_method :pop_without_readiness, :pop
  alias_method :pop, :pop_with_readiness
  
  def delay(time, *args)
    dequeue *args
    redis.set delay_key(*args), time.from_now
    enqueue *args
  end
  
  def delay_key(*args)
    "timeout:" + args.map(&:to_s).join(":")
  end
end
