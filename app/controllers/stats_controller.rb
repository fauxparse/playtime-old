class StatsController < ApplicationController
  respond_to :json
  require_login

  def index
    respond_with Jester.stats(*window)
  end

  def show
    begin
      stats = { all: jester.stats(*window("all")) }
      [0, -1].each do |i|
        year = Date.today.year + i
        stats[year] = jester.stats *window(year)
      end
      respond_with stats
    rescue MongoMapper::DocumentNotFound
      head :not_found
    end
  end

protected
  def jester
    @jester ||= Jester.find_by_slug! params[:id]
  end

  def window(year = nil)
    year ||= (params[:year] or "all")
    if year == "all"
      [100.years, Date.civil(2010, 1, 1)]
    else
      [1.year, Date.civil(year.to_i, 1, 1)]
    end
  end
end
