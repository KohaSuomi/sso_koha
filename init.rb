Rails.application.config.to_prepare do
  require_dependency 'patches/account_controller_sso_patch'
  require_dependency 'patches/user_patch'
  require_dependency 'hooks/controller_account_hook'
end

require 'redmine'

Redmine::Plugin.register :sso_koha do
  name 'Single sign-on from Koha'
  author 'Juhani Seppala'
  description 'Plugin implementing a SSO scheme between Koha and Redmine'
  version '0.1.0'
  url 'http://example.com/path/to/plugin'
  author_url 'vaarakirjastot.fi'
  settings :default => {'koha_auth_script_location' => '/svc/OPLIB/redmineSSOAuthCheck',
                        'login_redirect_url' => '/projects/fbox',
                        'use_ssl' => 'yes'},
           :partial => 'settings/sso_koha_settings'
end