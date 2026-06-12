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

# ── Demo seed ───────────────────────────────────────────────────────────────
# Creates open posts for the live demo. No fake users — real team members
# will join the chats during the demo.

Post.destroy_all

MAIN_EMAIL      = "luciea3011@gmail.com"
TEAMMATE1_EMAIL = "test@example.com"
TEAMMATE2_EMAIL = "cyril.faccin@outlook.fr"
TEAMMATE3_EMAIL = "toto1@gmail.com"

me         = User.find_by!(email: MAIN_EMAIL)
teammate1  = User.find_by!(email: TEAMMATE1_EMAIL)
teammate2  = User.find_by!(email: TEAMMATE2_EMAIL)
teammate3  = User.find_by!(email: TEAMMATE3_EMAIL)

apex       = Game.find_by!(name: "Apex Legends")
minecraft  = Game.find_by!(name: "Minecraft")
lol        = Game.find_by!(name: "League of Legends")
valorant   = Game.find_by!(name: "Valorant")
cs2        = Game.find_by!(name: "Counter-Strike 2")
rocket     = Game.find_by!(name: "Rocket League")
stardew    = Game.find_by!(name: "Stardew Valley")
among_us   = Game.find_by!(name: "Among Us")
sea        = Game.find_by!(name: "Sea of Thieves")
dbd        = Game.find_by!(name: "Dead by Daylight")
siege      = Game.find_by!(name: "Rainbow Six Siege")
fall_guys  = Game.find_by!(name: "Fall Guys")

posts_data = [
  { user: me,        title: "Diamond grind — LFG for ranked tonight",         game: apex,      slot: 3, language: "English", platforms: ["PC"], post_type: "Competitive" },
  { user: me,        title: "Cozy survival base, all welcome",                game: minecraft,  slot: 4, language: "English", platforms: ["PC"], post_type: "Chill"       },
  { user: me,        title: "Premier league — need 2 steady riflers",         game: cs2,        slot: 2, language: "English", platforms: ["PC"], post_type: "Competitive" },
  { user: teammate1, title: "Ranked climb — gold+ only, bonne ambiance",      game: lol,        slot: 2, language: "French",  platforms: ["PC"], post_type: "Competitive" },
  { user: teammate1, title: "Soirée détente Stardew, ferme coopérative",      game: stardew,    slot: 3, language: "French",  platforms: ["PC"], post_type: "Chill"       },
  { user: teammate1, title: "Chill Among Us lobby, 6–10 players, voice chat", game: among_us,   slot: 9, language: "English", platforms: ["PC"], post_type: "Fun"         },
  { user: teammate2, title: "Valorant ranked, Plat+, chill teammates",        game: valorant,   slot: 4, language: "English", platforms: ["PC"], post_type: "Competitive" },
  { user: teammate2, title: "Ranked 3v3, climbing to Diamond this season",    game: rocket,     slot: 2, language: "English", platforms: ["PC"], post_type: "Competitive" },
  { user: teammate2, title: "Survivor squad, we don't die alone",             game: dbd,        slot: 3, language: "English", platforms: ["PC"], post_type: "Fun"         },
  { user: teammate3, title: "Hochrangig Ranked — suche 2 erfahrene Spieler",  game: siege,      slot: 2, language: "German",  platforms: ["PC"], post_type: "Competitive" },
  { user: teammate3, title: "Sea of Thieves — tall tales and treasure hunts", game: sea,        slot: 3, language: "English", platforms: ["PC"], post_type: "Chill"       },
  { user: teammate3, title: "Fall Guys squad, sin presión y a divertirse",    game: fall_guys,  slot: 3, language: "Spanish", platforms: ["PC"], post_type: "Chill"       },
]

posts_data.each do |data|
  post = Post.create!(
    user:      data[:user],
    title:     data[:title],
    game:      data[:game],
    slot:      data[:slot],
    language:  data[:language],
    platforms: data[:platforms],
    post_type: data[:post_type],
    status:    "open"
  )

  chat = post.chat || post.create_chat!
  chat.users << data[:user] unless chat.users.exists?(data[:user].id)
end

puts "Seed done — #{posts_data.size} demo posts created for the live demo."
