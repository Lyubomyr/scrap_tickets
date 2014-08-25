class FlightsController < ApplicationController
  require 'pp'
  before_action :set_flight, only: [:show, :edit, :update, :destroy]

  def index
  end

  def search
    if flight_params[:title].present? && flight_params[:url].present?
      scrapper = Scrapper.new(flight_params)
      scrapper.start
      @results = Flight.where(title: flight_params[:title]).select(:from, :to, :price)
      respond_to do |format|
        format.js { render :results }
      end
    else
      render :index
    end
  end


  private
    # Use callbacks to share common setup or constraints between actions.
    def set_flight
      @flight = Flight.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def flight_params
      params.require(:flight).permit(:title, :url)
    end
end
