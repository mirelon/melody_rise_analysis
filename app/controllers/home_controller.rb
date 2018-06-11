class HomeController < ApplicationController
  def index
    @pacienti = Pacient.all
    @nahravky = Nahravka.all
  end

  def upload
    blob = ActiveStorage::Blob.create_after_upload!(
        io: StringIO.new(Base64.decode64(params[:data].split(",").last)),
        filename: DateTime.now.strftime('%Y%m%d-%H%M%S'),
        content_type: 'audio/wav'
    )
    pacient = Pacient.where(params.permit(:meno, :priezvisko, :vek, :pohlavie)).first_or_create
    nahravka = pacient.nahravky.create(file: blob)
    render plain: nahravka.analyze_file
  end
end