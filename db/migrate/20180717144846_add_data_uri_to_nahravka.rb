class AddDataUriToNahravka < ActiveRecord::Migration[5.2]
  def change
    add_column :nahravky, :data_uri, :string
  end
end
