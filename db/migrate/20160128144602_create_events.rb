class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.references :user, :index => true
      t.string :name
      t.string :event_id
      t.text :description
      t.text :location
      t.datetime :start
      t.datetime :end

      t.timestamps null: false
    end
  end
end
