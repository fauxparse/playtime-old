class StatsController < ApplicationController
  respond_to :json
  require_login

  def index
    respond_with Jester.stats(*window)
  end

  def show
    begin
      respond_with jester.stats(*window)
    rescue MongoMapper::DocumentNotFound
      head :not_found
    end
  end

protected
  def jester
    @jester ||= Jester.find_by_slug! params[:id]
  end

  def window
    start = if params.key? :year
      Date.civil(params[:year].to_i, 1, 1)
    else
      Date.civil(Date.today.year, 1, 1)
    end
    [1.year, start]
  end
end
