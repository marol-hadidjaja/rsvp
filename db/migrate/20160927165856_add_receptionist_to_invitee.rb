class AddReceptionistToInvitee < ActiveRecord::Migration
  def change
    change_table :invitees do |t|
      t.integer :receptionist_id, index: true
    end
  end
end
