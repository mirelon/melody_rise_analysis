class Pacient < ApplicationRecord
  has_many :nahravky
  enum pohlavie: [:♂, :♀]

  def display_name
    "#{meno} #{priezvisko}"
  end
end
