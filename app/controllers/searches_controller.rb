class SearchesController < ApplicationController
  require 'pp'
  before_action :set_search, only: [:show, :edit, :update, :destroy]

  def index
    @searches = Search.all
  end

  def new
    @search = Search.new
  end

  def create
    search = search_data(search_params)
    @search = Search.new search
    if @search.save
      # Scrapper.new(@search.id).start
      SearchWorker.perform_async(@search.id)
      redirect_to @search
    else
      render :new
    end
  end

  def find_search
    @search = Search.find_by(title: params[:title])
    SearchWorker.perform_async(@search.id) if params[:restart] == "true"
    redirect_to @search
  end

  def rerun_search
    search = Search.find(params[:id])
    new_search = {}
    new_search["title"] = "#{search[:title].sub(/ - rerun.*/, "")} - rerun at #{Time.now}"
    new_search["url"] = search[:url]
    @search = Search.new search_data(new_search)
    if @search.save
      # Scrapper.new(@search.id).start
      SearchWorker.perform_async(@search.id)
      redirect_to @search
    else
      render :new
    end
  end

  private

    def search_data(attrs)
      pp attrs
      url = attrs["url"]
      str_dates = url[/\d{6}\/\d{6}/].split("/")
      depart_date = DateTime.strptime(str_dates[0],"%g%m%d")
      return_date = DateTime.strptime(str_dates[1],"%g%m%d")
      search = attrs
      search["depart"] = depart_date
      search["return"] = return_date
      search
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_search
      @search = Search.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def search_params
      params.require(:search).permit(:title, :url)
    end
end
