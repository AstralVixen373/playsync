class CreateIdentities < ActiveRecord::Migration[8.1]
  def change
    create_table :identities do |t|
      t.string :image
      t.string :nickname
      t.string :provider
      t.string :refresh_token
      t.string :token
      t.string :uid
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
