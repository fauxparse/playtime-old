class ActivitiesController < ApplicationController
  require_login
  
  def index
    respond_to do |format|
      format.html do
        @activities = Activity.day date
      end
    end
  end
  
protected
  def date
    @date ||= if params[:year] and params[:month] and params[:day]
      Date.civil params[:year].to_i, params[:month].to_i, params[:day].to_i
    else
      Date.today
    end
  end
  helper_method :date
end
