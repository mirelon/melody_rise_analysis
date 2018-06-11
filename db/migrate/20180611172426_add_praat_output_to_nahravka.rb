class AddPraatOutputToNahravka < ActiveRecord::Migration[5.2]
  def change
    add_column :nahravky, :praat_output, :string
  end
end
