class ChangeColumnsInvitee < ActiveRecord::Migration
  def change
    change_table :invitees do |t|
      t.rename :response, :ceremonial_response
      t.boolean :reception_response
    end
  end
end
