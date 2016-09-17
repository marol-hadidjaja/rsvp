class Ability
  include CanCan::Ability

  def initialize(user)
    @user = user || User.new # for guest
    @user.roles.each { |role| send(role.name.downcase) }

    if @user.roles.size == 0
      can :read, :all #for guest without roles
    end
  end

  def admin
    can :manage, Event
    can :manage, Invitee
    can :manage, User
  end

  def receptionist
    can [:update_arrival_form, :update_arrival], Invitee
  end

  def invitee
    can [:invitation_response, :update_response], Invitee
  end
end
