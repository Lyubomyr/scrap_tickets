class SearchWorker
  include Sidekiq::Worker

  def perform(search_id)
    scrapper = Scrapper.new(search_id)
    puts "Starting  search with id:#{search_id}"
    scrapper.start
  end
end
