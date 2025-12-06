class Ability
  include CanCan::Ability

  def initialize(user)
    return unless user.present?

    if user.administrator?
      can :manage, :all
    elsif user.manager?
      can :read, :all
      can :manage, User, role: ['employee', 'manager']
      cannot [:create, :update, :delete], User, role: 'administrator' 
      can :manage, Sale
      can :manage, Product
    elsif user.employee?
      can :manage, Product
      can :manage, Sale
    end
  end
end