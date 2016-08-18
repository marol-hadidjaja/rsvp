class CreateImages < ActiveRecord::Migration
  def change
    create_table :images do |t|
=begin
      t.string :file
      t.float :file_size
      t.string :alt_text
      t.string :title
      t.string :content_type
=end
      t.attachment :file
      t.references :user, index: true

      t.timestamps null: false
    end
  end
end
