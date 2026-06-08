class MessagesController < ApplicationController
  MAX_MESSAGE_LENGTH = 250

  def create
    @chat = current_user.chats.find(params[:chat_id])
    @message = @chat.messages.build(message_params)
    @new_message = Message.new
    @message.user = current_user
    authorize @message

    if @message.content.to_s.length > MAX_MESSAGE_LENGTH
      redirect_to chat_path(@chat), alert: "Message is too long (max #{MAX_MESSAGE_LENGTH} characters)."
      return
    end

    if @message.save
      # redirect_to request.referer || chat_path(@chat)
      respond_to do |format|
        format.turbo_stream
      end
    else
      redirect_to request.referer || chat_path(@chat), alert: "Could not send message."
    end
  end

  private

  def message_params
    params.require(:message).permit(:content)
  end
end
