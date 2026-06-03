class AddGameToPosts < ActiveRecord::Migration[8.1]
  def change
    add_reference :posts, :game, null: false, foreign_key: true
  end
end
