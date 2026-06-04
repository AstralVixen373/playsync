class PostsController < ApplicationController
  include Pundit::Authorization

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  def index
    @posts = policy_scope(Post).with_free_slots.includes(:user).order(created_at: :desc)
    @post = Post.new
  end

  def show
    @post = find_post_or_placeholder
    authorize @post
    @chat = @post.chat
    @is_member = @post.member?(current_user)
    @message = Message.new
  end

  def new
    @post = Post.new
    authorize @post
  end

  def create
    @post = current_user.posts.new(post_params)
    authorize @post
    if @post.save
      # The creator is the first member of the match (counts as 1/capacity).
      chat = @post.create_chat!
      chat.users << current_user
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
    @post = Post.find(params[:id])
    authorize @post
    @post.destroy
    redirect_to posts_path(), notice: "post deleted.", status: :see_other
  end

  def join
    @post = Post.find(params[:id])
    authorize @post, :show?

    notice = nil
    alert = nil

    Post.transaction do
      post = Post.lock.find(@post.id)
      chat = post.chat || post.create_chat!

      if chat.users.exists?(current_user.id)
        notice = "Tu es déjà dans ce match."
      elsif post.full?
        alert = "Ce match est complet."
      else
        chat.users << current_user
        notice = "Tu as rejoint le match !"
      end
    end

    @post.reload
    broadcast_post_changes(@post)

    redirect_to post_path(@post), notice: notice, alert: alert
  end

  def leave
    @post = Post.find(params[:id])
    authorize @post, :show?

    if @post.user == current_user
      redirect_to post_path(@post), alert: "Le créateur ne peut pas quitter son propre match."
      return
    end

    @post.chat&.users&.delete(current_user)
    @post.reload
    broadcast_post_changes(@post)

    redirect_to posts_path, notice: "Tu as quitté le match."
  end

  private

  # Push live updates whenever a member count changes (join / leave).
  # Broadcasts are shared by every subscriber, so they can't be personalised
  # per viewer: the public list is rendered with current_user: nil (everyone
  # sees the generic "Join" card). The acting user is redirected and gets a
  # fresh, personalised page anyway.
  def broadcast_post_changes(post)
    # Re-render the whole public list: full posts drop out, freed ones come
    # back, counters stay fresh — without juggling append/remove/ordering.
    Turbo::StreamsChannel.broadcast_replace_to(
      "posts",
      target: "posts_list",
      partial: "posts/list",
      locals: { posts: Post.with_free_slots.includes(:user).order(created_at: :desc), current_user: nil }
    )

    # Refresh the slot counter on the post page for everyone watching it.
    Turbo::StreamsChannel.broadcast_replace_to(
      post,
      target: "#{ActionView::RecordIdentifier.dom_id(post)}_slots",
      partial: "posts/slots",
      locals: { post: post }
    )
  end

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
    params.require(:post).permit(:title, :game_id, :platform, :language, :post_type, :slot)
  end
end
