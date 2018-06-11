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
    actions
  end
end
