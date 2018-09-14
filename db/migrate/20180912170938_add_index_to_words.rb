class AddIndexToWords < ActiveRecord::Migration[5.2]
  def change
    enable_extension :citext
    change_column :words, :word, :citext
    add_index :words, :word
  end
end
