class RemoveGameFromPosts < ActiveRecord::Migration[8.1]
  def change
    remove_column :posts, :game, :string
  end
end
