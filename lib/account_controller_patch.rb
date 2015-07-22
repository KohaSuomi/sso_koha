module SSOKoha
  module AccountControllerPatch
    def self.included(base) # :nodoc:
      unloadable
      base.class_eval do
        skip_before_filter :verify_authenticity_token
        def successful_authentication(user)
          logger.info("REDEFINED\n")
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

      end
    end
  end
end
