class CreateSearch < ActiveRecord::Migration
  def change
    create_table :searches do |t|
      t.string :title
      t.string :url
      t.timestamps
    end
  end
end
