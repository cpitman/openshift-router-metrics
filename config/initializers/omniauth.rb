Rails.application.config.middleware.use OmniAuth::Builder do
  provider :openshift, {
    scope: ['user:full', 'user:info'],
    response_type: :code,
    client_id: 'router-stats',
    client_secret: 'super-secret',
    client_options: {
      redirect_uri: "http://router-stats-router-stats.rhel-cdk.10.1.2.2.xip.io/auth/openshift/callback",
      ssl: {verify: false},
    }
  }
end
