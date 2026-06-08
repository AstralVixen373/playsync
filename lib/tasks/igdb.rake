namespace :igdb do
  task import: :environment do
    IgdbImportJob.perform_now
  end
end
