class CreateEventsImages < ActiveRecord::Migration
  def change
    create_table :events_images do |t|
      t.references :event
      t.references :image

      t.timestamps null: false
    end
    add_index :events_images, [ :image_id, :event_id ], :unique => true
  end
end
