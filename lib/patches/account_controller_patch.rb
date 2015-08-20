# Patches the Redmine authentication controller
require_dependency 'account_controller'
module SSOKoha
  module Patches
    module AccountControllerPatch

      def self.included(base) # :nodoc:
        base.send(:include, InstanceMethods)
        base.class_eval do
          unloadable
          skip_before_filter :verify_authenticity_token

          alias_method_chain :successful_authentication, :sso



        end

      end

      module ClassMethods


      end

      module InstanceMethods

        def successful_authentication_with_sso(user)
          logger.info "Successful authentication for '#{user.login}' from #{request.remote_ip} at #{Time.now.utc}"
          # Valid user
          self.logged_user = user
          # generate a key and set cookie if autologin
          if params[:autologin] && Setting.autologin?
            set_autologin_cookie(user)
          end
          call_hook(:controller_account_success_authentication_after, {:user => user })
          if user.auth_source.nil?
            redirect_back_or_default my_page_path
          else
            as = AuthSource.find(user.auth_source_id)
            if as.name == 'Koha'
              redirect_to home_url + 'projects/fbox'
            else
              redirect_back_or_default my_page_path
            end
          end
        end

        def set_my_page_path(newpath = '/projects/fbox')
          self.my_page_path = newpath
        end

      end
    end
  end
end

unless AccountController.included_modules.include? SSOKoha::Patches::AccountControllerPatch
  AccountController.send(:include, SSOKoha::Patches::AccountControllerPatch)
end
