class CreateWords < ActiveRecord::Migration[5.2]
  def change
    create_table :words do |t|
      t.string :word
      t.string :lemma
      t.string :tag

      t.timestamps
    end
  end
end
