class Nahravka < ApplicationRecord
  belongs_to :pacient
  has_one_attached :file

  def wav_file
    key = file.blob.key
    Rails.application.root.join 'storage', key[0..1], key[2..3], key
  end

  def analyze_file
    executable = Rails.application.root.join('praat', 'praat')
    f0rise_praat = Rails.application.root.join('praat', 'f0rise.praat')
    praat_output = `#{executable} --run "#{f0rise_praat}" "#{wav_file}"`
    lines = praat_output.split("\n")
    praat_data = lines.map{|line| k,v = line.split(": "); [k,v]}.to_h # this allows praat output to contain nil values
    update_attributes({f0rise: praat_data["Rise percent"].to_i, praat_output: praat_output})
    praat_output
  end

  def wav_url
    Rails.application.routes.url_helpers.url_for(
        controller: 'active_storage/blobs',
        action: :show,
        signed_id: file.signed_id,
        filename: file.filename,
        only_path: true)
  end

  def as_json(options = {})
    super(options).merge(
                      wav_file: wav_file,
                      wav_url: wav_url
    )
  end
end
