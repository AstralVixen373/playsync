module ApplicationHelper
  # Flag SVG asset for each language in Post::LANGUAGES. "Other" has no flag and
  # falls back to a globe emoji in `option_icon`.
  LANGUAGE_FLAGS = {
    "English" => "flags/gb.svg",
    "French"  => "flags/fr.svg",
    "Spanish" => "flags/es.svg",
    "German"  => "flags/de.svg"
  }.freeze

  # Apple-style emoji image for each session type in Post::TYPES, plus the globe
  # used for the "Other" language. Served as images so the Apple glyphs render
  # identically on every OS (Windows/Android ship their own emoji fonts).
  EMOJI_IMAGES = {
    "Chill"       => "emojis/chill.png",
    "Fun"         => "emojis/fun.png",
    "Competitive" => "emojis/competitive.png",
    "Other"       => "emojis/globe.png"
  }.freeze

  # Native (endonym) display label for each language in Post::LANGUAGES, so the
  # card reads "Français" rather than the stored "French". Display-only — the
  # persisted value stays the canonical English name. Falls back to the raw name.
  LANGUAGE_LABELS = {
    "English" => "English",
    "French"  => "Français",
    "Spanish" => "Español",
    "German"  => "Deutsch",
    "Other"   => "Other"
  }.freeze

  def language_label(name)
    LANGUAGE_LABELS.fetch(name, name)
  end

  # Returns the icon markup for a filter option, picking the right glyph based
  # on whether it's a platform, language or session type. Flags and emojis
  # render as images (Apple flag/emoji glyphs don't render on Windows/Android).
  # Falls back to the platform icon (an <img>/<i>) for platforms.
  def option_icon(name, size: 16)
    if (flag = LANGUAGE_FLAGS[name])
      image_tag flag, alt: name, class: "flag-icon",
                      style: "width: #{size + 6}px; height: #{size}px; object-fit: cover; border-radius: 2px;"
    elsif (emoji = EMOJI_IMAGES[name])
      image_tag emoji, alt: name, class: "emoji-icon",
                       style: "width: #{size}px; height: #{size}px; object-fit: contain;"
    else
      platform_icon(name, size: size)
    end
  end
end
