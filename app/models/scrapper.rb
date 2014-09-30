# require File.expand_path("../../config/environment", __FILE__)
require 'capybara'
require 'capybara/dsl'
require 'capybara/webkit'
# require 'headless'

class Scrapper
  include ScrapperHelper
  include ActiveModel::Model
  include Capybara::DSL


# http://www.skyscanner.com.ua/transport/flights/kiev/blr/141003/141013/airfares-from-kiev-to-bengaluru-in-october-2014.html?rtn=1
# Capybara::Screenshot.screenshot_and_open_image

  attr_reader :title, :url, :dates, :from, :to, :from_to_range, :weekend_range, :search_count

  def initialize(search_id)
    @search = Search.find(search_id)
    @search_range = @search.search_range
    @title = @search.title
    @url = @search.url
    parse_dates()

    # Capybara options
    Capybara.default_driver    = :webkit
    Capybara.javascript_driver = :webkit
    Capybara.default_wait_time = 60
    Capybara.run_server = false
    @page = Capybara::Session.new(:webkit, @app)
    # Capybara.register_driver :webkit do |app|
    #   Capybara::Driver::Webkit.new(app, :ignore_ssl_errors => true)
    # end
    # if Rails.env.production?
    #   headless = Headless.new
    #   headless.start
    # end
  end

  def start
    @search.update(status: "Started")
    count = 0
    @forward_range.each do |forward_date|
      @backward_range.each do |backward_date|
        update_url(forward_date, backward_date)
        if price = search()
          flight = @search.flights.build(url: @url, from: forward_date, to: backward_date, price: price)
          flight.save ? count += 1 : (pp flight.errors.full_messages)
        end
      end
    end
    @search.update(status: "Completed")
  end

  protected
    def search
      start = Time.now
      pp @url
      @page.visit @url
      wait_for_search(@page)
      if @page.has_css?("li.day-list-item.clearfix")
        row = @page.first("li.day-list-item.clearfix")
        price = row.find(".mainquote a.mainquote-price").text()
      else
        price = 0
      end
      stop = Time.now
      @search_time = stop - start
      puts "Searched for #{@search_time} seconds."
      price
    end

    def parse_dates
      @str_dates = @url[/\d{6}\/\d{6}/].split("/")
      @forward_date = str_to_date @str_dates[0]
      @backward_date = str_to_date @str_dates[1]
      @forward_range = (@forward_date - @search_range)..(@forward_date + @search_range)
      @backward_range = (@backward_date - @search_range)..(@backward_date + @search_range)
    end

    def str_to_date(str)
      DateTime.strptime(str,"%g%m%d")
    end

    def date_to_str(date)
      date.strftime("%g%m%d")
    end

    def update_url(forward_date, backward_date)
      old_date = "#{@str_dates[0]}/#{@str_dates[1]}"
      new_date = "#{date_to_str(forward_date)}/#{date_to_str(backward_date)}"
      @url = @url.sub(old_date, new_date)
      @str_dates = @url[/\d{6}\/\d{6}/].split("/")
      @url
    end

    def search_count
      main_cycle = @from_to_range
      inner_cycle = @from_to_range - @weekend_range
      main_cycle * inner_cycle
    end
end
