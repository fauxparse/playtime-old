class AwardsController < ApplicationController
  require_login
  respond_to :json

  def index
    this_year = Date.civil(Date.today.year, 1, 1).to_time
    respond_with Award.where(created_at: { "$gte" => this_year }).sort(:created_at.desc)
  end

  def create
    @award = Award.new params[:award].except(:id)
    @award.author = current_jester
    @award.save!
    @award.like! current_jester
    render :json => @award
  end

  def update
    award.update_attributes params[:award]
    render :json => @award
  end

  def destroy
    award.destroy
    head :ok
  end

  def like
    award.like! current_jester
    render :nothing => true
  end

  def unlike
    award.unlike! current_jester
    render :nothing => true
  end

protected
  def award
    @award ||= Award.find params[:id]
  end
end
