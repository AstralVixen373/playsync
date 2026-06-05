class AddUniqueIndexesToChatsAndUserChats < ActiveRecord::Migration[8.1]
  def change
    add_index :chats, :post_id, unique: true, name: "index_chats_on_post_id_unique",
              if_not_exists: true
    add_index :user_chats, [:user_id, :chat_id], unique: true,
              name: "index_user_chats_on_user_id_and_chat_id_unique", if_not_exists: true
  end
end
