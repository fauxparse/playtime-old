class Jester
  include MongoMapper::Document

  key :name,   String
  key :email,  String
  key :slug,   String
  key :active, Boolean, default: true
  key :admin,  Boolean, default: false

  key :password_digest, String
  key :remember_token,  String
  
  include ActiveModel::SecurePassword
  has_secure_password
  attr_protected :remember_token

  before_create :generate_token
  
  validates_presence_of :name, :email, :slug
  before_validation :generate_slug

  def serializable_hash(options = {})
    super({ :except => [ :password_digest, :remember_token ] }.merge(options))
  end

  def self.factory(attrs)
    klass = case attrs[:type]
    when "Muso" then Muso
    else Jester
    end
    klass.new attrs.except(:type)
  end

  def self.authenticate(email, password)
    (find_by_email(email) or find_by_slug(email)).try(:authenticate, password)
  end

  def self.stats(window = 90.days, start_date = Date.today - window)
    start_date = start_date.to_time_in_current_zone.to_time
    map = """
      function() {
        for (id in this.cast) {
          var role = this.cast[id];
          emit(id, {
            available: 1,
            mc: role == 'mc' ? 1 : 0,
            last_mced: role == 'mc' ? this.date : 0,
            player: (role == 'player' || role == 'muso') ? 1 : 0,
            last_played: (role == 'player' || role == 'muso') ? this.date : 0
          });
        }
      }
      """
    reduce = """
      function(id, values) {
        var r = values.shift();
        values.forEach(function(v) {
          r.available += v.available;
          r.mc += v.mc;
          if (v.last_mced > r.last_mced) r.last_mced = v.last_mced;
          r.player += v.player;
          if (v.last_played > r.last_played) r.last_played = v.last_played;
        });
        r.ratio = r.available ? r.player / r.available : 0;
        return r;
      }
      """
    stats = Show.collection.map_reduce map, reduce,
      :out => { :inline => true }, :raw => true,
      :query => { :date => { :"$gte" => start_date, :"$lt" => start_date + window } }
    Hash[*stats["results"].map { |s| [s["_id"], s["value"].merge(:id => s["_id"])] }.flatten]
  end
  
  def stats(window = 90.days, start_date = Date.today - window)
    start_date = start_date.to_time_in_current_zone.to_time
    map = """
      function() {
        var role = this.cast['#{id}'],
            played_with = {},
            mced_with = {},
            mced = 0,
            played = 0;
        if (role) {
          if (role == 'player' || role == 'muso') {
            played = 1;
            for (var i in this.cast) if (i != '#{id}' && this.cast[i] == 'player')
              played_with[i] = 1;
          } else if (role == 'mc') {
            mced = 1;
            for (var i in this.cast) if (i != '#{id}' && this.cast[i] == 'player')
              mced_with[i] = 1;
          }
          emit('#{id}', {
            available: 1,
            mc: mced,
            last_mced: mced ? this.date : 0,
            mced_with: mced_with,
            player: played,
            last_played: played ? this.date : 0,
            played_with: played_with
          });
        }
      }
      """
    reduce = """
      function(id, values) {
        var r = values.shift();
        values.forEach(function(v) {
          r.available += v.available;
          r.mc += v.mc;
          if (v.last_mced > r.last_mced) r.last_mced = v.last_mced;
          r.player += v.player;
          if (v.last_played > r.last_played) r.last_played = v.last_played;
          for (var i in v.played_with) {
            r.played_with[i] = r.played_with[i] || 0;
            r.played_with[i] += v.played_with[i];
          }
          for (var i in v.mced_with) {
            r.mced_with[i] = r.mced_with[i] || 0;
            r.mced_with[i] += v.mced_with[i];
          }
        });
        r.ratio = r.available ? r.player / r.available : 0;
        return r;
      }
      """
    stats = Show.collection.map_reduce map, reduce,
      :out => { :inline => true }, :raw => true,
      :query => { :date => { :"$gte" => start_date, :"$lt" => start_date + window } }
    (stats["results"].first || {})["value"] || {}
  end

protected
  def generate_token
    begin
      self.remember_token = SecureRandom.urlsafe_base64
    end while Jester.exists?(:remember_token => self.remember_token)
  end
  
  def generate_slug
    self.slug ||= self.name.gsub(/\.$/, "").parameterize
  end
end
