class MatchPolicy < ApplicationPolicy
  def index?
    user.present?
  end
end
