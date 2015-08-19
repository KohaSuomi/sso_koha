Rails.application.config.to_prepare do
  require_dependency 'patches/account_controller_patch'
  require_dependency 'patches/user_patch'
end

require 'redmine'

Redmine::Plugin.register :sso_koha do
  name 'Single sign-on from Koha'
  author 'Juhani Seppala'
  description 'Plugin implementing a SSO scheme between Koha and Redmine'
  version '0.2.0'
  url 'vaarakirjastot.fi'
  author_url 'https://github.com/jseplae'
  settings :default => {'login_redirect_url' => '/projects/fbox'},
           :partial => 'settings/sso_koha_settings'
end