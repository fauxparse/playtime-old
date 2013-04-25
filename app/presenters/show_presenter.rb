class ShowPresenter
  def initialize(*shows)
    @shows = shows
  end
  
  def as_json(options = {})
    @shows.map { |show| self.class.show_json(show) }
  end
  
  def self.show_json(show)
    {
      date:  show.date,
      cast:  show.players.as_json(except: [:admin, :options]),
      notes: show.notes.tagged("web")
    }
  end
  
end