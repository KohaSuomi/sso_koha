require_dependency 'users_controller'
module SSOKoha
  module Patches
    module UsersControllerSSOPatch

      def self.included(base) # :nodoc:
        base.send(:include, InstanceMethods)
        base.class_eval do
          unloadable

          User.safe_attributes('auth_organization_id')

        end

      end

      module ClassMethods


      end

      module InstanceMethods

      end
    end
  end
end

unless UsersController.included_modules.include? SSOKoha::Patches::UsersControllerSSOPatch
  UsersController.send(:include, SSOKoha::Patches::UsersControllerSSOPatch)
end
