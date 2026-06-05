class ConvertPostPlatformToArray < ActiveRecord::Migration[8.1]
  def up
    add_column :posts, :platforms, :string, array: true, default: []

    # Backfill: turn the single platform string into a one-element array.
    execute <<~SQL.squish
      UPDATE posts
      SET platforms = ARRAY[platform]::varchar[]
      WHERE platform IS NOT NULL
    SQL

    remove_column :posts, :platform
  end

  def down
    add_column :posts, :platform, :string

    execute <<~SQL.squish
      UPDATE posts
      SET platform = platforms[1]
    SQL

    remove_column :posts, :platforms
  end
end
