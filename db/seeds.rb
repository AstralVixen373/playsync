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

# ── Dev seed ────────────────────────────────────────────────────────────────
# Creates test posts on the main account with different participant counts so
# the kick feature can be tested locally without a second browser session.

MAIN_EMAIL = "luciea3011@gmail.com"
me = User.find_by!(email: MAIN_EMAIL)

# Fake participants
test_users = [
  { username: "PlayerAlpha", email: "alpha@test.dev" },
  { username: "PlayerBeta",  email: "beta@test.dev"  },
  { username: "PlayerGamma", email: "gamma@test.dev" },
].map do |attrs|
  User.find_or_create_by!(email: attrs[:email]) do |u|
    u.username = attrs[:username]
    u.password = "password123"
  end
end

# Reuse any existing game, or create a placeholder
games = Game.all.to_a
games = [Game.create!(name: "Test Game", igdb_id: 0)] if games.empty?

posts_data = [
  { title: "[Seed] Solo — waiting for players", slot: 4, members: [] },
  { title: "[Seed] One buddy",                  slot: 3, members: test_users[0..0] },
  { title: "[Seed] Two buddies",                slot: 4, members: test_users[0..1] },
  { title: "[Seed] Full squad",                 slot: 4, members: test_users },
]

posts_data.each do |data|
  post = Post.find_or_create_by!(title: data[:title], user: me) do |p|
    p.game      = games.sample
    p.slot      = data[:slot]
    p.language  = "English"
    p.platforms = ["PC"]
    p.post_type = "Chill"
    p.status    = "open"
  end

  chat = post.chat || post.create_chat!

  ([me] + data[:members]).each do |user|
    chat.users << user unless chat.users.exists?(user.id)
  end
end

puts "Seed done — #{posts_data.size} test posts created/found for #{MAIN_EMAIL}."
