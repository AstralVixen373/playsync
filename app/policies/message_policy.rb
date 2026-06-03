class MessagePolicy < ApplicationPolicy
  def create?
    user.present?
  end
end
