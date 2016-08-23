class Event < ActiveRecord::Base
  belongs_to :user
  # has_many :invitees, through: :user_roles
  has_many :users, through: :user_roles
  has_many :user_roles
  has_and_belongs_to_many :images
  validates :name, :event_id, :ceremonial_location_name, :ceremonial_location_address, :ceremonial_start, :ceremonial_end,
    :reception_location_name, :reception_location_address, :reception_start, :reception_end, :global_password, :invitation, presence: true
  has_attached_file :invitation, styles: { thumb: "100x100#" },
    path: ":rails_root/public/event_images/user_id_:user_id/:style_invitation.:extension",
    url: "/invitation/:id/:style"
  validates_attachment_content_type :invitation, :content_type => ["image/jpg", "image/jpeg", "image/png", "image/gif"]

  # interpolate in paperclip
  Paperclip.interpolates :user_id do |attachment, style|
    attachment.instance.user_id
  end

  Paperclip.interpolates :id do |attachment, style|
    attachment.instance.id
  end

  def invitees
    Invitee.where(event_id: id)
  end

  def start_wib
    self.ceremonial_start.in_time_zone('Bangkok').strftime('%d-%B-%Y %H:%M')
  end

  def end_wib
    self.ceremonial_end.in_time_zone('Bangkok').strftime('%d-%B-%Y %H:%M')
    # @event.ceremonial_end.getlocal("+07:00").strftime("%d-%B-%Y %H:%M")
  end

  def the_day
    self.ceremonial_start.strftime("%A, %d<sup>#{ self.ceremonial_start.day.ordinal }</sup> %B %Y").html_safe
  end
end
