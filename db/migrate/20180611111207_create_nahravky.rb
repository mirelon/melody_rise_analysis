class CreateNahravky < ActiveRecord::Migration[5.2]
  def change
    create_table :nahravky do |t|
      t.string :filename
      t.integer :f0rise
      t.references :pacient, foreign_key: true

      t.timestamps
    end
  end
end
