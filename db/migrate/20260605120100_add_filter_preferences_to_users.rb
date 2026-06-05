class AddFilterPreferencesToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :preferred_game_ids, :integer, array: true, default: []
    add_column :users, :preferred_platforms, :string, array: true, default: []
    add_column :users, :preferred_post_types, :string, array: true, default: []
    add_column :users, :preferred_language, :string
  end
end
