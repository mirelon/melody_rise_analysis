ActiveAdmin.register Pacient do
  index do
    column :id
    column :created_at
    column :meno
    column :priezvisko
    column :vek
    tag_column :pohlavie
    column :nahravky do |pacient|
      link_to pacient.nahravky.count, admin_nahravky_path(q: {pacient_id_eq: pacient.id})
    end
    column :average_f0rise do |pacient|
      pacient.nahravky.average(:f0rise)
    end
    actions
  end

  show do
    attributes_table do
      row :meno
      row :priezvisko
      row :vek
      row :pohlavie
      row :created_at
      row :updated_at
      row :nahravky do |pacient|
        link_to pacient.nahravky.count, admin_nahravky_path(q: {pacient_id_eq: pacient.id})
      end
      row :average_f0rise do |pacient|
        pacient.nahravky.average(:f0rise)
      end
    end
    active_admin_comments
  end
end
