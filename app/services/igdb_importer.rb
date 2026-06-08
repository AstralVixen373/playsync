require "net/http"
require "json"

class IgdbImporter
  def self.import_games(offset = 0)
    uri = URI("https://api.igdb.com/v4/games")

    request = Net::HTTP::Post.new(uri)

    request["Client-ID"] = ENV["TWITCH_CLIENT_ID"]
    request["Authorization"] = "Bearer #{ENV['TWITCH_ACCESS_TOKEN']}"

    request.body = <<~QUERY
      fields id,name,cover.image_id,platforms,multiplayer_modes;
      where platforms = (6,130,167,169) & multiplayer_modes != null;
      sort popularity asc;
      limit 500;
      offset #{offset};
    QUERY

    response = Net::HTTP.start(
      uri.hostname,
      uri.port,
      use_ssl: true
    ) do |http|
      http.request(request)
    end

    games = JSON.parse(response.body)

    games.each do |game|
      record = Game.find_or_initialize_by(igdb_id: game["id"])
      record.name = game["name"]

      # `cover` is an expanded object (cover.image_id), absent when the game has
      # no cover on IGDB. Only overwrite when present so a re-import never wipes
      # a cover we already stored.
      cover_image_id = game.dig("cover", "image_id")
      record.cover_image_id = cover_image_id if cover_image_id.present?

      record.save!
    end

    games.size
  end
end
