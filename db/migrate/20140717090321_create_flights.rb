class CreateFlights < ActiveRecord::Migration
  def change
    create_table :flights do |t|
      t.integer :search_id
      t.string :url
      t.string :price
      t.date :from
      t.date :to
      t.timestamps
    end
  end
end
