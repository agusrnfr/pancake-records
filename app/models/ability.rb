class Ability
  include CanCan::Ability

  def initialize(user)
    return unless user.present?

    if user.administrator?
      can :manage, :all
    elsif user.manager?
      can :read, :all
      can :manage, Sale
    elsif user.employee?
      can :read, Product
      can :create, Sale
    end
  end
end