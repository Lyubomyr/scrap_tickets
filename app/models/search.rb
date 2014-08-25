class Search < ActiveRecord::Base
  has_many :flights
  validates :title, :presence => true
  # , uniqueness: true
  validates :url, :presence => true
end
