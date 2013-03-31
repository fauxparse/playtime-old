class Show
  include MongoMapper::Document
  include Icalendar
  
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
  
  def start_time
    date.to_time + 22.hours + 15.minutes
  end
  
  def end_time
    start_time + 90.minutes
  end
  
  def id=(value)
    self.date = Date.civil *value.split("-").map { |d| d.to_i(10) }
  end
  
  def description
    roles = self.players
    str = ""
    { mc: "MC", player: "Players", muso: "Muso", notes: "Notes" }.each_pair do |role, label|
      str += "#{label}: #{roles[role].to_sentence}\n" if roles[role]
    end
    str
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

  def last
    Jester.last_played_before date
  end

  def players
    players = {}
    except = %w(unavailable available)
    cast.each_pair do |id, role|
      unless except.include? role
        (players[role] ||= []) << id
      end
    end
    ids = players.collect { |role, ids| ids.select { |id| /[a-z0-f]{24}/i === id } }.flatten
    jesters = Hash[*Jester.find(ids).collect { |j| [j.id.to_s, j] }.flatten ]
    for role in players.keys
      players[role].map! { |id| jesters[id] || id }
    end
    players.with_indifferent_access
  end

  def player_emails
    emails = players.values.collect do |jesters|
      jesters.collect { |j| j.respond_to?(:email) ? j.email : nil }.flatten
    end
    emails.flatten
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
    super({ :except => :date }.merge(options))
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
  
  def self.calendar
    calendar = Calendar.new
    calendar.custom_property "X-WR-CALNAME", "Scared Scriptless"

    calendar.timezone do
      timezone_id "Pacific/Auckland"
      
      daylight do
        timezone_offset_from "+1200"
        timezone_offset_to   "+1300"
        timezone_name        "NZDT"
        dtstart              "19700927T020000"
        recurrence_rules     ["FREQ=YEARLY;BYMONTH=9;BYDAY=-1SU"]
      end
    
      standard do
        timezone_offset_from "+1300"
        timezone_offset_to   "+1200"
        timezone_name        "NZST"
        dtstart              "19700405T030000"
        recurrence_rules     ["FREQ=YEARLY;BYMONTH=4;BYDAY=1SU"]
      end
      
    end
    
    shows = where date: {
      "$gt" => (Date.today - 1.month).to_time,
      "$lt" => (Date.today + 2.months).to_time
    }
    shows.each do |show|
      calendar.event do
        dtstart     show.start_time.to_datetime
        dtend       show.end_time.to_datetime
        summary     "Scared Scriptless"
        description show.description
        location    "The Court Theatre"
      end
    end
      
    calendar
  end
  
  def self.timezone
    timezone = Icalendar::Timezone.new
    daylight = Icalendar::Daylight.new
    standard = Icalendar::Standard.new

    timezone.timezone_id =            "Pacific/Auckland"
    
    timezone.daylight do
      timezone_offset_from "+1300"
      timezone_offset_to   "+1200"
      timezone_name        "NZDT"
      dtstart              "19700927T020000"
      recurrence_rules     ["FREQ=YEARLY;BYMONTH=9;BYDAY=-1SU"]
    end
    
    timezone.standard do
      timezone_offset_from "+1200"
      timezone_offset_to   "+1300"
      timezone_name        "NZST"
      dtstart              "19700405T030000"
      recurrence_rules     ["FREQ=YEARLY;BYMONTH=4;BYDAY=1SU"]
    end

    timezone
  end
  
end
