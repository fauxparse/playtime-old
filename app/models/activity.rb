class Activity
  include MongoMapper::Document
  
  WINDOW = 10.minutes

  belongs_to :jester
  key        :action
  belongs_to :trackable, polymorphic: true
  key        :time, Time
  
  ensure_index :time
  
  scope :sorted, sort(:"$natural" => -1)
  scope :latest, lambda { |n| sorted.limit(n) }
  
  def match(activity)
    jester_id       == activity.jester_id and
    action          == activity.action and
    trackable.class == activity.trackable.class and
    (activity.time - time).abs < WINDOW
  end

  def self.log!(params)
    logger.info params.inspect
    Activity.create!(
      jester:    params[:jester],
      action:    params[:action],
      trackable: params[:trackable],
      time:      Time.now
    )
  end
  
  def self.day(date = Date.today)
    start = date.to_time
    finish = start + 1.day
    activities = sorted.where time: { :"$gte" => start, :"$lt" => finish }
    activities.inject([]) do |groups, activity|
      if groups.empty? or !groups.last.last.match(activity)
        groups + [[activity]]
      else
        groups.push(groups.pop + [activity])
      end
    end
  end
end
