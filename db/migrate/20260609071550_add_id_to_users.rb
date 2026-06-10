class AddIdToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :steamid, :string
    add_column :users, :steamname, :string
    add_column :users, :twitchid, :string
    add_column :users, :twitchname, :string
  end
end
