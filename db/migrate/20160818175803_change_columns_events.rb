class ChangeColumnsEvents < ActiveRecord::Migration
  def change
    change_table :events do |t|
      t.rename :start, :ceremonial_start
      t.rename :end, :ceremonial_end
      t.string :ceremonial_location_name
      t.rename :location, :ceremonial_location_address
      t.datetime :reception_start
      t.datetime :reception_end
      t.string :reception_location_name
      t.text :reception_location_address
      t.attachment :invitation
      t.string :global_password
    end
  end
end
