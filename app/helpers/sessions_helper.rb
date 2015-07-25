module SessionsHelper
  def current_user=(user)
    @current_user = user
  end

  def current_token=(token)
	  @current_token = token
  end


  def current_user
    @current_user ||= session[:current_user]
  end

  def current_token
	@current_token ||= session[:current_token]
  end

  def current_user?(user)
    user == current_user
  end

  def sign_in(user)
    session[:current_user] = user
    self.current_user = user
  end

  def sign_out
    session.delete(:current_user)
	session.delete(:current_token)
  end

  def signed_in?
    !current_user.nil?
  end

  def setauthheader(token)
	  session[:current_token] = token
	  self.current_token = token
  end
end

UserManagementWebapp::App.helpers SessionsHelper

