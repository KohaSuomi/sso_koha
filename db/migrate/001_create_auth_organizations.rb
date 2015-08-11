class CreateAuthOrganizations < ActiveRecord::Migration
  def change
    create_table :auth_organizations do |t|
      t.string :name, :null => false
      t.timestamp :created_on
    end
  end
end

def self.down
  drop_table :auth_organizations
end