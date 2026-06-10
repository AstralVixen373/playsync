module PlatformsHelper
  # Maps a platform name (from Post::PLATFORMS) to its brand logo asset.
  # Platforms without a dedicated logo fall back to a Font Awesome glyph in
  # `platform_icon`, so the UI stays consistent across all platforms.
  PLATFORM_LOGOS = {
    "PS5"             => "platforms/playstation.svg",
    "Xbox"            => "platforms/xbox.svg",
    "Nintendo Switch" => "platforms/nintendoswitch.svg"
  }.freeze

  # Font Awesome fallbacks for platforms we don't have a brand logo for.
  PLATFORM_FA_ICONS = {
    "PC"     => "fa-solid fa-desktop",
    "Mobile" => "fa-solid fa-mobile-screen-button"
  }.freeze

  # i18n-safe slug for each platform, used to key the per-platform handle
  # labels (Gamertag, PSN ID …) without spaces in the translation keys.
  PLATFORM_HANDLE_SLUGS = {
    "PC"              => "pc",
    "PS5"             => "ps5",
    "Xbox"            => "xbox",
    "Nintendo Switch" => "nintendo_switch",
    "Mobile"          => "mobile"
  }.freeze

  # The localized identifier label for a platform's handle field (e.g. "Xbox"
  # => "Gamertag"). Falls back to the platform name.
  def platform_handle_label(platform)
    slug = PLATFORM_HANDLE_SLUGS[platform]
    slug ? t("devise.registrations.edit.platform_handles.#{slug}") : platform
  end

  # Returns the icon markup for a platform (a brand <img> or a Font Awesome
  # <i>), sized to `size` px, or nil when the name isn't a known platform.
  def platform_icon(name, size: 16)
    if (logo = PLATFORM_LOGOS[name])
      image_tag logo, alt: name, class: "platform-icon",
                      style: "width: #{size}px; height: #{size}px; object-fit: contain;"
    elsif (fa = PLATFORM_FA_ICONS[name])
      content_tag :i, "", class: "platform-icon #{fa}",
                          style: "font-size: #{size}px; width: #{size}px; text-align: center;"
    end
  end

  # A platform as an inline icon + name, e.g. for detail pages.
  def platform_label(name, size: 16)
    content_tag :span, class: "platform-label",
                       style: "display: inline-flex; align-items: center; gap: 0.35rem;" do
      safe_join([platform_icon(name, size: size), name].compact)
    end
  end

  # A list of platforms rendered as inline icon + name chips.
  def platform_list(platforms, size: 16)
    return "" if platforms.blank?

    safe_join(Array(platforms).map { |name| platform_label(name, size: size) }, " ")
  end
end
