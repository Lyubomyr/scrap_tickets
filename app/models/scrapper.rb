require 'open-uri'
require 'rubygems'
require 'capybara'
require 'capybara/dsl'
require 'capybara-webkit'
require 'active_record'

class Scrapper
  include ScrapperHelper
  include ActiveModel::Model
  include Capybara::DSL

# http://www.skyscanner.com.ua/transport/flights/kiev/blr/141003/141013/airfares-from-kiev-to-bengaluru-in-october-2014.html?rtn=1
# Capybara::Screenshot.screenshot_and_open_image

  attr_reader :title, :url, :dates, :from, :to, :from_to_range, :weekend_range, :search_count

  def initialize(options={})
    # options
    @weekend_range = 7

    # varibles
    @title = options[:title]
    @url = options[:url]
    # @url_parts = @url.split(/\d{6}\/\d{6}/)
    @dates = @url[/\d{6}\/\d{6}/].split("/")
    @from = @dates[0].to_i
    @to = @dates[1].to_i
    @from_to_range = @to - @from
    @search_count = search_count()

    # Capybara options
    Capybara.default_wait_time = 60
    Capybara.run_server = false
    Capybara.current_driver = :webkit
  end

  def start
    count = 0
    @from.upto(@to) do |from|
      (@from + @weekend_range).upto(@to) do |to|
        @url = update_url(from, to)
        @from = from
        @to = to
        price = search()
        flight = Flight.new(title: @title, url: @url, from: @from, to: @to, price: price)
        flight.save ? count += 1 : (pp flight.errors.full_messages)
      end
    end
  end

  protected
    def search
      start = Time.now
      visit @url
      wait_for_search
      row = first("li.day-list-item.clearfix")
      price = row.find(".mainquote a.mainquote-price").text()
      stop = Time.now
      # gon.watch.search_time =  * (stop - start).round
      price
    end

    def update_url(from, to)
      old_date = "#{@from}/#{@to}"
      new_date = "#{from}/#{to}"
      @url.sub(old_date, new_date)
    end

    def search_count
      main_cycle = @from_to_range
      inner_cycle = @from_to_range - @weekend_range
      main_cycle * inner_cycle
    end
end