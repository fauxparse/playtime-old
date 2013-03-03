class JestersController < ApplicationController
  respond_to :json
  require_login

  def index
    respond_with Jester.all
  end

  def show
    begin
      respond_with jester
    rescue MongoMapper::DocumentNotFound
      head :not_found
    end
  end

  def create
    @jester = Jester.new params[:jester]
    if @jester.password.blank?
      @jester.password = @jester.password_confirmation = "sp4c3jump"
    end

    if @jester.save
      render json: @jester
    else
      respond_with @jester.errors, status: :unprocessable_entity
    end
  end

  def update
    jester.update_attributes params[:jester]
    render json: jester
  end

  def photo
    jester.avatar = params[:files].first
    jester.save!
    render json: {
      files: [{
        name:          jester.avatar.identifier,
        size:          jester.avatar.size,
        url:           jester.avatar.web.url,
        delete_url:    photo_jester_url(jester),
        delete_type:   "DELETE"
      }]
    }
  end

  def delete_photo
    jester.avatar.remove!
    jester.update_attributes avatar_filename: nil
    head :ok
  end

protected
  def jester
    @jester ||= Jester.find_by_slug! params[:id]
  end

end
