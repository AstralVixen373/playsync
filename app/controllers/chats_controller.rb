class ChatsController < ApplicationController
  def show
    @chat = current_user.chats.find(params[:id])
    @message = Message.new
  end

  def create
    @post = current_user.posts.find(params[:post_id])
    @chat = Chat.new(post: @post, user: current_user)

    if @chat.save
      redirect_to chat_path(@chat)
    else
      redirect_to post_path(@post), alert: "Problem with chat creation"
    end
  end
end
