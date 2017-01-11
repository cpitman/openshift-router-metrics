class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  def current_user
    if session[:username]
      {:username => session[:username]}
    end
  end

  def require_login
    redirect_to '/auth/openshift' if current_user.nil?
  end

  def access_token
    client = OAuth2::Client.new('router-stats', 'super-secret', {site: 'https://10.1.2.2:8443/', connection_opts: { ssl: {verify: false} } } )

    OAuth2::AccessToken.new client, session[:credentials]['token']
  end

  def service_account
    service_account_token = IO.read('/var/run/secrets/kubernetes.io/serviceaccount/token')
    Faraday.new 'https://10.1.2.2:8443', headers: {'Authorization': "Bearer #{service_account_token}"}, ssl: {verify: false}
  end

  helper_method :current_user
end
