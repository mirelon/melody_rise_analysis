class CreatePacienti < ActiveRecord::Migration[5.2]
  def change
    create_table :pacienti do |t|
      t.string :meno
      t.string :priezvisko
      t.integer :vek
      t.integer :pohlavie

      t.timestamps
    end
  end
end
