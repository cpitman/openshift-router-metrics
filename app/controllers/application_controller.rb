class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  def current_user
    if session[:username]
      {:username => session[:username]}
    end
  end

  def require_login
    reset_session if !session[:token_creation_time].nil? and session[:token_creation_time] < 24.hours.ago
    redirect_to '/auth/openshift' if current_user.nil?
  end

  def access_token
    client = OAuth2::Client.new(ENV['OAUTHCLIENT_NAME'], ENV['OAUTHCLIENT_SECRET'], {site: ENV['PUBLIC_MASTER_URL'], connection_opts: { ssl: {verify:  (ENV['VERIFY_MASTER_TLS'] || 'true') == 'true'} } } )

    OAuth2::AccessToken.new client, session[:credentials]['token']
  end

  def service_account
    service_account_token = IO.read('/var/run/secrets/kubernetes.io/serviceaccount/token')
    Faraday.new ENV['PUBLIC_MASTER_URL'], headers: {'Authorization': "Bearer #{service_account_token}"}, ssl: {verify:  (ENV['VERIFY_MASTER_TLS'] || 'true') == 'true'}
  end

  helper_method :current_user
end
