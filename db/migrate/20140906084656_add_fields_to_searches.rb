class AddFieldsToSearches < ActiveRecord::Migration
  def change
    add_column :searches, :depart, :date
    add_column :searches, :return, :date
    add_column :searches, :status, :string
    add_column :searches, :search_range, :integer, default: 3
  end
end
