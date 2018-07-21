ActiveAdmin.register Nahravka do

  show do
    attributes_table do
      row :id
      row :created_at
      row :pacient
      row :f0rise
      row :data_uri do |nahravka|
        render 'partials/audio', data_uri: nahravka.data_uri
      end
    end
  end

  index do
    column :id
    column :created_at
    column :pacient
    column :f0rise
    column :data_uri do |nahravka|
      audio_tag url_for(nahravka.data_uri), controls: true
    end
    actions
  end

  member_action :analyze_file, method: :post do
    resource.analyze_file
    redirect_to admin_nahravka_path(resource), notice: "Nakrávka bola analyzovaná."
  end

  action_item :analyze_file, only: :show do
    link_to 'Analyzovať', analyze_file_admin_nahravka_path, method: :post
  end

end
