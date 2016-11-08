class Ability
  include CanCan::Ability

  def initialize(user)
    if user.has_role? :admin
      can :manage, User
      can :manage, Campaign
      can :manage, Role
      can :manage, :platform_supports
    end

    if !user.has_role? :admin
      can [:show, :edit, :update], User do |u|
        u.id == user.id
      end

      cannot :manage, :platform_supports
    end 
  end
end
