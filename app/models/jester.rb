class Jester
  include MongoMapper::Document

  key :name,   String
  key :email,  String
  key :slug,   String
  key :active, Boolean, default: true

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
