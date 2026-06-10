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

  COLOR_PAIRS = [
  { name: "Rose",    light: "#FADADD", dark: "#7B2D35" },
  { name: "Indigo",  light: "#DDE3F5", dark: "#2D3A7B" },
  { name: "Émeraude",light: "#D4F5E2", dark: "#1B5E35" },
  { name: "Ambre",   light: "#FFF0C2", dark: "#7A4F00" },
  { name: "Ardoise", light: "#E2E8F0", dark: "#2D3748" },
  { name: "Corail",  light: "#FFE5DE", dark: "#7B2D1B" },
  { name: "Violet",  light: "#EDE0F7", dark: "#4A1E7A" },
  { name: "Cyan",    light: "#D0F4F8", dark: "#0F505C" },
  { name: "Olive",   light: "#E8EED0", dark: "#3B4A10" },
  { name: "Pêche",   light: "#FDECD5", dark: "#6E3510" },
  { name: "Sarcelle",light: "#CCEFEA", dark: "#0D4840" },
  { name: "Brique",  light: "#F5DDD5", dark: "#6B2018" }].freeze

  def random_color_for(user)
    COLOR_PAIRS[user.id % COLOR_PAIRS.length]
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
