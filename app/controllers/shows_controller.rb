class ShowsController < ApplicationController
  respond_to :json, except: :calendar
  respond_to :ics, only: :index
  require_login except: [:calendar, :weekend, :cast]
  
  def index
    respond_to do |format|
      format.json do
        params[:year]  ||= Date.today.year
        params[:month] ||= Date.today.month
        render json: Show.month(params[:year].to_s.to_i(10), params[:month].to_s.to_i(10)).as_json(:methods => :last)
      end
    end
  end
  
  def weekend
    render json: ShowPresenter.new(*Show.weekend(date))
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
    track show
    respond_with show
  end
  
  def batch
    shows = []
    if params.key? :changes
      shows = Show.apply params[:changes]
      shows.each do |show, cast_changed|
        if cast_changed
          Resque.delay 10.minutes, ShowNotifier, show.id, current_jester.id
          track show, "update"
        else
          track show, "availability"
        end
      end
    end
    render json: shows.map(&:first)
  end
  
  def cast
    @shows = Show.where(date: {
      "$gt" => (Date.today - 1.day).to_time,
      "$lt" => (Date.today + 1.month).to_time
    }).group_by(&:month).to_a.sort_by(&:first)
    
    render layout: false
  end

protected
  def show
    @show ||= Show.date(date)
  end
  
  def date
    @date ||= Date.civil(
      (params[:year]  || Date.today.year ).to_s.to_i(10),
      (params[:month] || Date.today.month).to_s.to_i(10),
      (params[:day]   || Date.today.day  ).to_s.to_i(10),
    )
  end

end
