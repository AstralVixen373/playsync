class PostsController < ApplicationController
  include Pundit::Authorization

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  def index
    @posts = policy_scope(Post).open.with_free_slots.includes(:user, :game).order(created_at: :desc)

    # On a fresh visit (no `committed` flag) the filters default to the user's
    # saved preferences. Once the user touches the form, `committed` is set and
    # we honour exactly what they selected (including clearing everything).
    committed = params[:committed].present?
    @selected_game_ids   = committed ? clean_filter(params[:game_ids])   : current_user.preferred_game_ids
    @selected_platforms  = committed ? clean_filter(params[:platforms])  : current_user.preferred_platforms
    @selected_post_types = committed ? clean_filter(params[:post_types]) : current_user.preferred_post_types
    @selected_language   = committed ? params[:language].presence        : current_user.preferred_language

    @posts = @posts.with_games(@selected_game_ids)
                   .with_platforms(@selected_platforms)
                   .with_types(@selected_post_types)
                   .for_language(@selected_language)

    @selected_games = Game.where(id: @selected_game_ids)
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
    # Pre-fill the form from the user's saved preferences. A post holds a single
    # game / type / language, so we take the first preferred value for those;
    # platforms is multi-valued so all preferred platforms are pre-selected.
    @post = Post.new(
      platforms: current_user.preferred_platforms,
      post_type: current_user.preferred_post_types.first,
      language: current_user.preferred_language,
      game_id: current_user.preferred_game_ids.first
    )
    authorize @post
  end

  def create
    @post = current_user.posts.new(post_params)
    authorize @post
    if @post.save
      # The creator is the first member of the match (counts as 1/capacity).
      chat = @post.create_chat!
      chat.users << current_user
      redirect_to post_path(@post), notice: t("posts.notices.created")
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
    redirect_to posts_path(), notice: t("posts.notices.deleted"), status: :see_other
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
        notice = t("posts.notices.already_member")
      elsif post.full?
        alert = t("posts.notices.full")
      else
        chat.users << current_user
        notice = t("posts.notices.joined")
      end
    end

    @post.reload
    broadcast_post_changes(@post)

    redirect_to post_path(@post), notice: notice, alert: alert
  end

  def finish
    @post = Post.find(params[:id])
    authorize @post

    if @post.update(status: "finished")
      broadcast_post_changes(@post)
      redirect_to post_path(@post), notice: "Match marked as finished."
    else
      redirect_to post_path(@post), alert: "Could not update the match status."
    end
  end

  def leave
    @post = Post.find(params[:id])
    authorize @post, :show?

    if @post.user == current_user
      redirect_to post_path(@post), alert: t("posts.notices.creator_cannot_leave")
      return
    end

    @post.chat&.users&.delete(current_user)
    @post.reload
    broadcast_post_changes(@post)

    redirect_to posts_path, notice: t("posts.notices.left")
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
      locals: { posts: Post.open.with_free_slots.includes(:user).order(created_at: :desc), current_user: nil }
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
    redirect_to root_path, alert: t("posts.notices.not_authorized")
  end

  def post_params
    params.require(:post).permit(:title, :game_id, :language, :post_type, :slot, platforms: [])
  end

  def clean_filter(values)
    Array(values).reject(&:blank?)
  end
end
