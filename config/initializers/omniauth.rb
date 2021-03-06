if Gitlab::LDAP::Config.enabled?
  module OmniAuth::Strategies
    Gitlab::LDAP::Config.available_servers.each do |server|
      # do not redeclare LDAP
      next if server['provider_name'] == 'ldap'
      const_set(server['provider_class'], Class.new(LDAP))
    end
  end
end

OmniAuth.config.full_host = Settings.gitlab['base_url']
OmniAuth.config.allowed_request_methods = [:post]
# In case of auto sign-in, the GET method is used (users don't get to click on a button)
OmniAuth.config.allowed_request_methods << :get if Gitlab.config.omniauth.auto_sign_in_with_provider.present?
OmniAuth.config.before_request_phase do |env|
  Gitlab::RequestForgeryProtection.call(env)
end

if Gitlab.config.omniauth.enabled
  provider_names = Gitlab.config.omniauth.providers.map(&:name)
  require 'omniauth-kerberos' if provider_names.include?('kerberos')
end

module OmniAuth
  module Strategies
    autoload :Bitbucket, Rails.root.join('lib', 'omni_auth', 'strategies', 'bitbucket')
  end
end
