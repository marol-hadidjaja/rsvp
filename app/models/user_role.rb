class UserRole < ActiveRecord::Base
  belongs_to :user
  belongs_to :event
  belongs_to :role

  validates :user_id, :event_id, :role_id, presence: true
end
