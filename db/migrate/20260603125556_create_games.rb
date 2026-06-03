class CreateGames < ActiveRecord::Migration[8.1]
  def change
    create_table :games do |t|
      t.integer :igdb_id
      t.string :name

      t.timestamps
    end
  end
end
