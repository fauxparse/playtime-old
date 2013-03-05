class Award
  include MongoMapper::Document

  belongs_to :author, :class => Jester
  key :nominees, String
  key :content,  String
  key :category, String
  key :likes,    Array, :default => lambda { [] }
  timestamps!

  def like!(jester)
    unless likes.include? jester.id
      self.likes = likes + [jester.id]
      save!
    end
  end

  def unlike!(jester)
    if likes.include? jester.id
      self.likes = likes.reject { |j| j == jester.id }
      save!
    end
  end

end
