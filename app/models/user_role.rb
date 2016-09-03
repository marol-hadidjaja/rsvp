class UserRole < ActiveRecord::Base
  belongs_to :user, dependent: :destroy
  belongs_to :event, dependent: :destroy
  belongs_to :role, dependent: :destroy

  validates :user_id, :event_id, :role_id, presence: true
end
