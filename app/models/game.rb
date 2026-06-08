class Game < ApplicationRecord
  has_many :posts, dependent: :destroy

  # IGDB serves images from a CDN; the stored `cover_image_id` is the hash that
  # slots into the URL. Sizes are IGDB "image size" presets, e.g. t_cover_small,
  # t_cover_big, t_720p. See https://api-docs.igdb.com/#images
  IGDB_IMAGE_BASE = "https://images.igdb.com/igdb/image/upload".freeze

  def cover?
    cover_image_id.present?
  end

  # Returns the IGDB cover URL at the given size, or nil when no cover is stored
  # so callers can fall back to a placeholder.
  def cover_url(size: "t_cover_big")
    return unless cover?

    "#{IGDB_IMAGE_BASE}/#{size}/#{cover_image_id}.jpg"
  end
end
