class Nahravka < ApplicationRecord
  belongs_to :pacient

  def analyze_file
    file_path = store_as_file
    executable = Rails.application.root.join('praat', 'praat')
    f0rise_praat = Rails.application.root.join('praat', 'f0rise.praat')
    praat_output = `#{executable} --run "#{f0rise_praat}" "#{file_path}"`
    lines = praat_output.split("\n")
    praat_data = lines.map{|line| k,v = line.split(": "); [k,v]}.to_h # this allows praat output to contain nil values
    update_attributes({f0rise: praat_data["Rise percent"].to_i, praat_output: praat_output})
    praat_output
  end

  def filename
    created_at.strftime('%Y%m%d-%H%M%S')
  end

  def store_as_file
    filename = DateTime.now.strftime('%Y%m%d-%H%M%S') + ".wav"
    file = Tempfile.new(filename)
    file.binmode
    file.write(Base64.decode64(data_uri.split(",").last))
    file.path
  end

  def self.histogram
    data = group('ROUND(f0rise, -1)').count.map{|k,v| [k.to_i, v]}.to_h
    keys = (data.keys.min..data.keys.max).step(10).to_a
    keys.map{|key| [key, data[key] || 0]}.to_h
  end
end
