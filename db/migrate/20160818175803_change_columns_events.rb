class ChangeColumnsEvents < ActiveRecord::Migration
  def change
    change_table :events do |t|
      t.rename :start, :ceremonial_start
      t.rename :end, :ceremonial_end
      t.rename :location, :ceremonial_location
      t.datetime :reception_start
      t.datetime :reception_end
      t.string :reception_location
    end
  end
end
