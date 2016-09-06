class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # relations
  # has_one :invitee, dependent: :destroy

  has_many :events, through: :user_roles
  has_many :roles, through: :user_roles
  has_many :user_roles
  after_destroy :destroy_invitee

  def has_role? (role)
    self.roles.map(&:name).uniq.include?(role)
  end

  def has_role_for_event? (role, event)
    !self.user_roles.where(role_id: Role.find_by_name(role), event_id: event).empty?
  end

  def destroy_invitee
    Invitee.where(email: email).destroy_all
  end
end
