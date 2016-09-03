class CreateUserRoles < ActiveRecord::Migration
  def change
    create_table :user_roles do |t|
      t.references :user, index: true
      t.references :role, index: true
      t.references :event, index: true

      t.timestamps null: false
    end
  end
end
