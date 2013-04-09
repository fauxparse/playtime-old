class ShowNotifier
  @queue = :email
  
  def self.perform(id, jester_id)
    show = Show.find id
    jester = Jester.find jester_id
    Postman.casting_notification(show, jester).deliver
  end
  
end