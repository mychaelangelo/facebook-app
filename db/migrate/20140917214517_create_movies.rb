class CreateMovies < ActiveRecord::Migration
  def change
    create_table :movies do |t|
      t.string :rotten_id
      t.string :title

      t.timestamps
    end
  end
end
