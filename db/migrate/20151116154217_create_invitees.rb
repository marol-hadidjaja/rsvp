class CreateInvitees < ActiveRecord::Migration
  def change
    create_table :invitees do |t|
      t.string :name
      t.string :relation
      t.integer :number
      t.string :email
      t.text :address
      t.string :phone
      t.boolean :response
      t.boolean :arrival

      t.timestamps null: false
    end
  end
end
