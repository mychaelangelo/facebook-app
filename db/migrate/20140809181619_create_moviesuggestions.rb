class CreateMoviesuggestions < ActiveRecord::Migration
  def change
    create_table :moviesuggestions do |t|
      t.string :movies_liked, :array => true, :default => '{}'
      t.string :movies_suggested, :array => true, :default => '{}'

      t.references :user, index: true

      t.timestamps
    end
  end
end
