class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :username
      t.string :password
      t.string :email
      t.date :created_at
      t.date :updated_at

      t.timestamps null: false
    end
  end
end
