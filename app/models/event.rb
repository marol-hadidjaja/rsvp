class Event < ActiveRecord::Base
  belongs_to :user
  # has_many :invitees, through: :user_roles
  has_many :users, through: :user_roles
  has_many :user_roles
  has_and_belongs_to_many :images

  def invitees
    Invitee.where(event_id: id)
  end

  def start_wib
=begin
    start_time = self.start.to_datetime
    DateTime.new(start_time.year, start_time.month, start_time.day,
                 start_time.hour, start_time.minute, start_time.second, '+7').strftime('%d-%m-%Y %H:%M')
    self.start.strftime('%d-%m-%Y %H:%M')
=end
    self.start.in_time_zone('Bangkok').strftime('%d-%m-%Y %H:%M')
  end

  def end_wib
=begin
    end_time = self.end.to_datetime
    DateTime.new(end_time.year, end_time.month, end_time.day,
                 end_time.hour, end_time.minute, end_time.second, '+7').strftime('%d-%m-%Y %H:%M')
=end
    self.end.in_time_zone('Bangkok').strftime('%d-%m-%Y %H:%M')
  end
end
