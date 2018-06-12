class Pacient < ApplicationRecord
  has_many :nahravky
  enum pohlavie: [:♂, :♀]

  def display_name
    "#{meno} #{priezvisko}"
  end

  def histogram
    data = nahravky.group('ROUND(f0rise, -1)').count.map{|k,v| [k.to_i, v]}.to_h
    keys = (data.keys.min..data.keys.max).step(10).to_a
    keys.map{|key| [key, data[key] || 0]}.to_h
  end
end
