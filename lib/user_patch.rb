require 'user'
module SSOKoha
  # Patches or modifies Redmine koha dynamically
  module UserPatch
    def self.included(base) # :nodoc:
      base.extend(ClassMethods)
      base.send(:include, InstanceMethods)

      base.class_eval do
        unloadable

        after_create :set_kohasuomi_prefs
      end

    end

    module ClassMethods
    end

    module InstanceMethods

      # Automatically set some roles upon user creation (fbox -> Reporter)
      def set_kohasuomi_prefs
        unless self.auth_source.nil?
          as = AuthSource.find(self.auth_source_id)
          if as.name == 'Koha'
            member = Member.new
            member.user = self
            member.project = Project.find('fbox')
            member.roles = [Role.find_by_name('Reporter')]
            member.save
          end
        end
      end

    end
  end
end
