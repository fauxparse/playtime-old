class ApplicationController < ActionController::Base
  protect_from_forgery

protected
  def current_jester
    @current_jester ||= Jester.find_by_remember_token(cookies[:login]) if !!cookies[:login]
  end
  helper_method :current_jester
  
  def logged_in?
    !current_jester.nil?
  end
  helper_method :logged_in?
  
  def require_login
    unless logged_in?
      respond_to do |format|
        format.json { head :forbidden }
      end
      return false
    end
  end
  
  def self.require_login(options = {})
    before_filter :require_login, options
  end
end
