class AddCoverImageIdToGames < ActiveRecord::Migration[8.1]
  def change
    add_column :games, :cover_image_id, :string
  end
end
