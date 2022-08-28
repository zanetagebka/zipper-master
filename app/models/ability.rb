# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    can :read, Attachment, user_id: user.id
  end
end
