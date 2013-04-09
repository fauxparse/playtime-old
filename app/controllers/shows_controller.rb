class ShowsController < ApplicationController
  respond_to :json, :except => :calendar
  respond_to :ics, :only => :index
  require_login :except => :calendar
  
  def index
    respond_to do |format|
      format.json do
        params[:year]  ||= Date.today.year
        params[:month] ||= Date.today.month
        render :json => Show.month(params[:year].to_s.to_i(10), params[:month].to_s.to_i(10)).as_json(:methods => :last)
      end
    end
  end
  
  def calendar
    respond_to do |format|
      format.ics do
        render text: Show.calendar.to_ical
      end
    end
  end
  
  def edit
    respond_with show
  end
  
  def update
    show.update_attributes params[:show]
    respond_with show
  end
  
  def batch
    shows = []
    if params.key? :changes
      shows = Show.apply params[:changes]
      for show in shows
        Resque.delay 10.minutes, ShowNotifier, show.id, current_jester.id
      end
    end
    render :json => shows
  end

protected
  def show
    @show ||= Show.date(Date.civil(
      params[:year].to_s.to_i(10),
      params[:month].to_s.to_i(10),
      params[:day].to_s.to_i(10)
    ))
  end

end
