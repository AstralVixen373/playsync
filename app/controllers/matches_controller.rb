class MatchesController < ApplicationController
  skip_after_action :verify_policy_scoped, only: %i[index show]

  def index
    authorize :match, :index?

    base = Post.where(
      id: current_user.posts.select(:id)
    ).or(
      Post.where(
        id: Post.joins(chat: :user_chats)
                .where(user_chats: { user_id: current_user.id })
                .where.not(user_id: current_user.id)
                .select(:id)
      )
    ).includes(:user, :game, chat: :users)

    @posts = base.with_games(params[:game_id])
                 .with_platforms(params[:platform])
                 .with_types(params[:post_type])
                 .for_language(params[:language])
                 .order(Arel.sql("CASE WHEN posts.status = 'open' THEN 0 ELSE 1 END"), created_at: :desc)

    @favourited_ids = current_user.favourites.where(post_id: @posts).pluck(:post_id).to_set

    if params[:favourites_only] == "1"
      @posts = @posts.where(id: @favourited_ids.to_a)
    end
  end

  def show
    @post = Post.includes(:user, chat: [:messages, :users]).find(params[:id])
    authorize @post
  end
end
