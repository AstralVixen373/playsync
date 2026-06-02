class MessagesController < ApplicationController
  before_action :authenticate_user!
  MAX_MESSAGE_LENGTH = 250
  def create
    @chat = current_user.chats.find(params[:chat_id])
    @message = Message.new(user: current_user)
    @post = @chat.post
    @message = @chat.messages.build(message_params)
    @message.user_id = "user"

    if @message.content.to_s.length > MAX_MESSAGE_LENGTH
      @message.errors.add(:content, "is too long")
      return render_message_form(:unprocessable_entity)
    end

    @message.save
  end

  private

  def message_params
    params.require(:message).permit(:content)
  end
end
