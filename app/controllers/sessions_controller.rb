class SessionsController < ApplicationController
  require_login :except => :login
  respond_to :json
  
  def current
    render_login_information
  end
  
  def login
    if @jester = Jester.authenticate(params[:email], params[:password])
      cookies.permanent[:login] = @jester.remember_token
      render_login_information
    else
      head :forbidden
    end
  end

  def logout
    cookies.delete :login
    redirect_to :root
  end
  
protected
  def render_login_information
    render json: {
      current: current_jester.id,
      jesters: Jester.all
    }
  end
  
end
