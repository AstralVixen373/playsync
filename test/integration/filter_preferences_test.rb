require "test_helper"

class FilterPreferencesTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @game = Game.create!(name: "Valorant")
    @other_game = Game.create!(name: "Overwatch")
    @user = User.create!(email: "pref@example.com", password: "password123")
    sign_in @user
  end

  test "search page renders and pre-fills saved preferences" do
    @user.update!(
      preferred_platforms: ["PC"],
      preferred_post_types: ["Competitive"],
      preferred_language: "English",
      preferred_game_ids: [@game.id]
    )

    get posts_path
    assert_response :success
    # The platform dropdown shows PC checked.
    assert_match %r{name="platforms\[\]" value="PC"\s+checked}, response.body
    # The preferred game appears as a chip.
    assert_match "Valorant", response.body
  end

  test "search filters posts by selected platforms (overlap)" do
    pc_post = create_post(platforms: ["PC"], title: "PC squad")
    ps_post = create_post(platforms: ["PS5"], title: "PS5 squad")

    get posts_path(committed: "1", platforms: ["PC"])
    assert_response :success
    assert_match "PC squad", response.body
    assert_no_match "PS5 squad", response.body
  end

  test "new post form is pre-filled from preferences" do
    @user.update!(preferred_platforms: ["PC", "PS5"], preferred_post_types: ["Chill"], preferred_language: "French")

    get new_post_path
    assert_response :success
    assert_match %r{name="post\[platforms\]\[\]" value="PC"\s+checked}, response.body
    assert_match %r{name="post\[platforms\]\[\]" value="PS5"\s+checked}, response.body
  end

  test "creating a post with multiple platforms" do
    assert_difference "Post.count", 1 do
      post posts_path, params: { post: {
        title: "Crossplay night", game_id: @game.id,
        platforms: ["PC", "PS5", ""], post_type: "Fun",
        language: "English", slot: 3
      } }
    end
    assert_equal ["PC", "PS5"], Post.last.platforms
  end

  test "updating profile saves filter preferences" do
    patch user_registration_path, params: { user: {
      email: @user.email,
      preferred_platforms: ["PC", ""],
      preferred_post_types: ["Competitive", ""],
      preferred_language: "Spanish",
      preferred_game_ids: [@game.id.to_s, ""]
    } }

    @user.reload
    assert_equal ["PC"], @user.preferred_platforms
    assert_equal ["Competitive"], @user.preferred_post_types
    assert_equal "Spanish", @user.preferred_language
    assert_equal [@game.id], @user.preferred_game_ids
  end

  private

  def create_post(platforms:, title:)
    Post.create!(
      title: title, user: @user, game: @game, platforms: platforms,
      post_type: "Chill", language: "English", slot: 2
    ).tap { |p| p.create_chat!.users << @user }
  end
end
