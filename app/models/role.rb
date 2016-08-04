class Role < ActiveRecord::Base
  has_many :users, through: :user_roles
  has_many :user_roles
end
