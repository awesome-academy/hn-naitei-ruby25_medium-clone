# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize user
    alias_action :update, :destroy, to: :modify
    can :read, :all
    return if user.blank?

    can :create, Article
    can :modify, Article, user_id: user.id
    can :create, Comment
    can :new_reply, Comment
    can :create_reply, Comment
    can :modify, Comment, user_id: user.id
    can :create, Relationship, follower_id: user.id
    can :destroy, Relationship, follower_id: user.id
    can :read, Notification, user_id: user.id
    can :mark_read_all, Notification, user_id: user.id
    can :destroy, Notification, user_id: user.id
    can :modify, User, id: user.id
  end
end
