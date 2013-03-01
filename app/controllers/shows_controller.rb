class ShowsController < ApplicationController
  respond_to :json
  require_login
  
  def index
    respond_to do |format|
      format.json do
        params[:year]  ||= Date.today.year
        params[:month] ||= Date.today.month
        render :json => Show.month(params[:year].to_s.to_i(10), params[:month].to_s.to_i(10))
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
    shows = Show.apply params[:changes] if params.key? :changes
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
