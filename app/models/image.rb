class Image < ActiveRecord::Base
  has_and_belongs_to_many :events
  belongs_to :user
  has_attached_file :file, styles: { thumb: "100x100#" },
    path: ":rails_root/public/event_images/user_id_:user_id/:style_:filename",
    url: "/images/:id/:style"
  validates_attachment_content_type :file, :content_type => ["image/jpg", "image/jpeg", "image/png", "image/gif"]

  # interpolate in paperclip
  Paperclip.interpolates :user_id do |attachment, style|
    attachment.instance.user_id
  end

  Paperclip.interpolates :id do |attachment, style|
    attachment.instance.id
  end
end
