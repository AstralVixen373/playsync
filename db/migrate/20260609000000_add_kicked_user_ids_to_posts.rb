class AddKickedUserIdsToPosts < ActiveRecord::Migration[8.1]
  def change
    add_column :posts, :kicked_user_ids, :integer, array: true, default: []
  end
end
