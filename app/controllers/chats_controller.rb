class ChatsController < ApplicationController
  def show
    @chat = current_user.chats.find(params[:id])
    @messages = @chat.messages.includes(:user).order(:created_at)
    @message = Message.new
    authorize @chat
  end

  def create
    @post = Post.find(params[:post_id])
    authorize @post, :show?
    # Joining a match (and the slot limit) is handled by PostsController#join.
    redirect_to post_path(@post)
  end
end
