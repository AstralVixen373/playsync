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
    @post = current_user.posts.new(post_params)
    authorize @post
    if @post.save
      redirect_to post_path(@post), notice: "Post créé avec succès."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @post = params[:id].present? ? Post.find(params[:id]) : Post.new
    authorize @post
  end

  def update
    @post = params[:id].present? ? Post.find(params[:id]) : Post.new
    authorize @post
    if @post.update(post_params)
      redirect_to post_path(@post)
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @post = params[:id].present? ? Post.find(params[:id]) : Post.new
    authorize @post
    @post.destroy
    redirect_to posts_path, notice: "post deleted."
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

  def post_params
    params.require(:post).permit(:title, :game, :platform, :language, :post_type, :slot)
  end
end
