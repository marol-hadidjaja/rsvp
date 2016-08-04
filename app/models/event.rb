class Event < ActiveRecord::Base
  belongs_to :user
  has_many :invitees, through: :user_roles
  has_many :users, through: :user_roles
  has_many :user_roles
end
