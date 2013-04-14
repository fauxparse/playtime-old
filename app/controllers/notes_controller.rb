class NotesController < ApplicationController
  require_login
  respond_to :json
  
  def index
    respond_with show.notes
  end
  
  def create
    show.notes = show.notes + [Note.new(params[:note].except(:id))]
    show.save
    track show, "notes"
    render json: @note
  end

  def destroy
    show.notes = show.notes.to_a.delete_if { |note| note.id.to_s == params[:id].to_s }
    show.save
    head :ok
  end
  
protected
  def show
    @show ||= Show.date Date.civil(params[:year].to_i, params[:month].to_i, params[:day].to_i)
  end
  
end
