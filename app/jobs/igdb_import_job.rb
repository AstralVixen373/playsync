class IgdbImportJob < ApplicationJob
  queue_as :default

  def perform(max_pages: nil)
    # Do something later
    Rails.logger.info("=== IGDB IMPORT STARTED ===")
    offset = 0
    pages = 0

    loop do
      imported = IgdbImporter.import_games(offset)
      break if imported.zero?

      pages += 1
      break if max_pages && pages >= max_pages

      offset += 500
    end
  end
end
