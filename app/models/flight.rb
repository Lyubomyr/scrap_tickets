class Flight < ActiveRecord::Base
  validates :title, :presence => true, uniqueness: true
  validates :url, :presence => true
end
