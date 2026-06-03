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
    @chat = @post.chat || @post.build_chat
    @chat.save if @chat.new_record?
    @chat.users << current_user unless @chat.users.include?(current_user)
    redirect_to chat_path(@chat)
  end
end
