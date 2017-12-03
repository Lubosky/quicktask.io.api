class WorkspacePolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope.accessible_by(user)
    end
  end
end
