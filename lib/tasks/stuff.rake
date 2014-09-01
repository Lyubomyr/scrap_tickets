namespace :stuff do
  desc "Clear rails cache"
  task :clear_cache => :environment do
    Rails.cache.clear
  end
end