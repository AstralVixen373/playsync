class AddPlatformHandlesToUsers < ActiveRecord::Migration[8.1]
  def change
    # Per-platform usernames/IDs the user enters by hand (e.g. Xbox Gamertag,
    # PSN ID). Keyed by platform name from Post::PLATFORMS.
    add_column :users, :platform_handles, :jsonb, default: {}, null: false
  end
end
