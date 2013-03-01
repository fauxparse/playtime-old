class Show
  include MongoMapper::Document
  
  key :cast, Hash, :default => lambda { Hash.new }
  key :date, Date
  many :notes

  FRIDAY = 5
  SATURDAY = 6
  DAYS_WITH_SHOWS = [ FRIDAY, SATURDAY ].freeze
  
  def date=(value)
    write_key :date, value
    self._id = Show.date_key value
  end
  
  def id=(value)
    self.date = Date.civil *value.split("-").map { |d| d.to_i(10) }
  end
  
  def apply(changes)
    changes.each do |id, role|
      if role.nil?
        cast.delete id
      else
        cast[id] = role
      end
    end
    self
  end
  
  def self.apply(changes)
    shows = []
    changes.each do |id, casting|
      show = find(id).apply(casting)
      show.save
      shows.push show
    end
    shows
  end
  
  def serializable_hash(options = {})
    super({ except: :date }.merge(options))
  end
  
  def self.date_key(date)
    date.to_s :db
  end
  
  def self.date(date)
    find_or_create_by_id date_key(date)
  end
  
  def self.month(year, month)
    first = Date.civil year, month, 1
    last = first + 1.month
    from_db = Hash[*where(:date => { "$gte" => first.to_time, "$lt" => last.to_time }).map { |s| [s.id, s] }.flatten]
    dates = (first...last).select { |d| DAYS_WITH_SHOWS.include? d.wday }
    dates.map do |d|
      from_db[date_key(d)] or date(d)
    end
  end
  
end
