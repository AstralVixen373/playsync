# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# Backfill: every post's creator must be a member of its chat so the slot
# counter starts at 1/capacity (data only — no schema change). Idempotent.
Post.includes(:chat).find_each do |post|
  chat = post.chat || post.create_chat!
  chat.users << post.user unless chat.users.exists?(post.user_id)
end
