require_dependency 'account_controller_patch'
require_dependency 'user_patch'

Rails.configuration.to_prepare do
  require_dependency 'user'
  require_dependency 'account_controller'
  # Guards against including the module multiple time (like in tests)
  # and registering multiple callbacks
  unless User.included_modules.include? SSOKoha::UserPatch
    User.send(:include, SSOKoha::UserPatch)
  end

  unless AccountController.included_modules.include? SSOKoha::AccountControllerPatch
    AccountController.send(:include, SSOKoha::AccountControllerPatch)
  end

end

Redmine::Plugin.register :sso_koha do
  name 'Single sign-on from Koha'
  author 'Juhani Seppala'
  description 'Plugin implementing a SSO scheme between Koha and Redmine'
  version '0.0.1'
  url 'http://example.com/path/to/plugin'
  author_url 'vaarakirjastot.fi'
  settings :default => {'koha_auth_script_url' => 'http://kohapreprod3:8080/cgi-bin/koha/svc/OPLIB/redmineSSOAuthCheck',
                        'login_redirect_url' => '/projects/fbox'},
           :partial => 'settings/sso_koha_settings'
end

#class Hooks < Redmine::Hook::ViewListener
#  def controller_account_success_authentication_after(context={})
#    redirect_url = 'vaarakirjastot.fi'
#    context[:request].params[:back_url] = redirect_url
#    return ''
#  end
#end
