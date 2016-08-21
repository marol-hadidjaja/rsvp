class Event < ActiveRecord::Base
  belongs_to :user
  # has_many :invitees, through: :user_roles
  has_many :users, through: :user_roles
  has_many :user_roles
  has_and_belongs_to_many :images
  validates :name, :event_id, :ceremonial_location, :ceremonial_start, :ceremonial_end,
    :reception_location, :reception_start, :reception_end, presence: true

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
