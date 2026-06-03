class MatchesController < ApplicationController
  skip_after_action :verify_policy_scoped, only: %i[index show]

  def index
    authorize :match, :index?

    created = current_user.posts.includes(:user)
    joined  = Post.joins(chat: :user_chats)
                  .where(user_chats: { user_id: current_user.id })
                  .where.not(user_id: current_user.id)
                  .includes(:user)

    @posts = (created + joined).uniq(&:id)
  end

  def show
    @post = Post.includes(:user, chat: [:messages, :users]).find(params[:id])
    authorize @post
  end
end
