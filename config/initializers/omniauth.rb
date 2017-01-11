Rails.application.config.middleware.use OmniAuth::Builder do
  provider :openshift, {
    scope: ['user:full', 'user:info'],
    response_type: :code,
    client_id: ENV['OAUTHCLIENT_NAME'] || 'openshift-router-metrics',
    client_secret: ENV['OAUTHCLIENT_SECRET'],
    client_options: {
      redirect_uri: "#{ENV['HOSTNAME']}/auth/openshift/callback",
      ssl: {verify: (ENV['VERIFY_MASTER_TLS'] || 'true') == 'true'},
    }
  }
end
