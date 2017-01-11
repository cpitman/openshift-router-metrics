class SessionsController < ApplicationController
  def create
    session[:username]    = request.env['omniauth.auth']['info']['nickname']
    session[:uid]         = request.env['omniauth.auth']['uid']
    session[:credentials] = request.env['omniauth.auth']['credentials']
    redirect_to '/'
  end

  def destroy
    reset_session
    redirect_to '/'
  end
end
