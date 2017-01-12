require 'uri'

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :openshift, {
    scope: ['user:full', 'user:info'],
    response_type: :code,
    client_id: ENV['OAUTHCLIENT_NAME'] || 'openshift-router-metrics',
    client_secret: ENV['OAUTHCLIENT_SECRET'],
    client_options: {
      site: ENV['PUBLIC_MASTER_URL'],
      redirect_uri: URI.join((ENV['PUBLIC_URL'] || 'http://example.com'), '/auth/openshift/callback').to_s,
      ssl: {verify: (ENV['VERIFY_MASTER_TLS'] || 'true') == 'true'},
    }
  }
end
