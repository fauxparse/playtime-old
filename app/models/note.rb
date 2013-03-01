class Note
  include MongoMapper::EmbeddedDocument
  key :content, String
  key :time,    DateTime
  timestamps!
  
  belongs_to :author, :class => Jester
end
