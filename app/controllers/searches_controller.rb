class SearchesController < ApplicationController
  require 'pp'
  before_action :set_search, only: [:show, :edit, :update, :destroy]

  def index
  end

  def new
    @search = Search.new
  end

  # def create
  #   @search = Search.find_or_initialize_by search_params
  #   respond_to do |format|
  #     if @search.save
  #       scrapper = Scrapper.new(@search)
  #       scrapper.test
  #       @results = @search.flights
  #       format.js { render :results }
  #     else
  #       format.html { render :new }
  #     end
  #   end
  # end

  def create
    test = Struct.new("Test", :title, :url).new
    test.title = "test"
    test.url = "http://www.google.com"
    pp test.url
    scrapper = Scrapper.new(test)
    scrapper.test
    render nothing: true
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_search
      @search = Search.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def search_params
      params.require(:search).permit(:title, :url)
    end
end
