# Class AuthOrganization corresponds to the users's organizations based on the
# login@hostname login names provided by this plugin.
class AuthOrganization < ActiveRecord::Base
  unloadable

#  attr_accessor :id

  self.table_name = 'auth_organizations'
  has_many :users, :class_name => 'User'

  validates :name, presence: true
  attr_protected :id

end