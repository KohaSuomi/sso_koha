module SSOKoha
  module Hooks
    class ControllerAccountHook < Redmine::Hook::ViewListener
      def controller_account_success_authentication_after(context={})
#        user = context[:user]
#        puts 'Hook called!\n'
#        puts user.to_s
#        as = user.auth_source
#        puts as.to_s
#        if as.name == 'Koha'
#          puts context[:controller].my_page_path
#          puts context[:controller].(:my_page_path, '/projects/fbox')
#        end
      end
    end
  end
end