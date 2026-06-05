require "net/http"
require "json"

class IgdbImporter
  def self.import_games(offset = 0)
    puts "Importing games..."

    uri = URI("https://api.igdb.com/v4/games")

    request = Net::HTTP::Post.new(uri)

    request["Client-ID"] = ENV["TWITCH_CLIENT_ID"]
    request["Authorization"] = "Bearer #{ENV['TWITCH_ACCESS_TOKEN']}"

    request.body = <<~QUERY
      fields id,name,cover;
      where platforms = (6, 48, 167);
      sort name asc;
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
      Game.find_or_initialize_by(igdb_id: game["id"]).update!(
        name: game["name"]
      )
    end

    games.size
  end
end
