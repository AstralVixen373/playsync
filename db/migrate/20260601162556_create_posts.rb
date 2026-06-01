class CreatePosts < ActiveRecord::Migration[8.1]
  def change
    create_table :posts do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :slot
      t.string :platform
      t.string :post_type
      t.string :game
      t.string :language
      t.string :title

      t.timestamps
    end
  end
end
