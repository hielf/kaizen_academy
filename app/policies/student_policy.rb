class StudentPolicy < ApplicationPolicy
  def index?
    user.admin?
  end

  def show?
    user.admin? || (user.student? && user == record)
  end

  def create?
    user.admin?
  end

  def update?
    user.admin? || (user.student? && user == record)
  end

  def destroy?
    user.admin?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      if user.admin?
        scope.all
      elsif user.student?
        scope.where(id: user.id)
      else
        scope.none
      end
    end
  end
end 