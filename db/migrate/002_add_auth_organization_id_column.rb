# Add auth organization column to the users table.
class AddAuthOrganizationIdColumn < ActiveRecord::Migration
  def change
    add_column :users, :auth_organization_id, :integer, :null => true
  end
end

def self.down
  remove_column :users, :auth_organization_id
end