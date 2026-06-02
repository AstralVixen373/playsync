class PostsController < ApplicationController
  include Pundit::Authorization

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  def index
    @posts = policy_scope(Post).includes(:user).order(created_at: :desc)
  end

  def show
    @post = find_post_or_placeholder
    authorize @post
    @chat = @post.chat || @post.build_chat
  end

  def new
    @post = Post.new
    authorize @post
  end

  def create
    authorize Post
  end

  def edit
    @post = params[:id].present? ? Post.find(params[:id]) : Post.new
    authorize @post
  end

  def update
    @post = params[:id].present? ? Post.find(params[:id]) : Post.new
    authorize @post
  end

  def destroy
    @post = params[:id].present? ? Post.find(params[:id]) : Post.new
    authorize @post
  end

  private

  def find_post_or_placeholder
    return Post.includes(:user).find(params[:id]) if params[:id].present?

    Post.new(
      title: "Post preview",
      user: User.new(email: "unknown@example.com"),
      created_at: Time.current
    )
  end

  def user_not_authorized
    redirect_to root_path, alert: "You are not authorized to perform this action."
  end
end
