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

  def destroy_invitee
    Invitee.where(email: email).destroy_all
  end
end
