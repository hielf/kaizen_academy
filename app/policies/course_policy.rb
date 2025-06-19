class CoursePolicy < ApplicationPolicy
  def index?
    user.admin?
  end

  def show?
    user.admin? || (user.student? && user.school == record.school && record.term.school == user.school)
  end

  def create?
    user.admin?
  end

  def update?
    user.admin?
  end

  def destroy?
    user.admin?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      if user.admin?
        scope.all
      elsif user.student?
        scope.joins(:school, :term).where(schools: { id: user.school_id }, terms: { school_id: user.school_id })
      else
        scope.none
      end
    end
  end
end 