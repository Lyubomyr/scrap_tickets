class Flight < ActiveRecord::Base
  belongs_to :search

  scope :by_dates, -> (from, to) { find_by(from: from, to: to) }
end
