class NahravkaController < ApiController
  def create
    if params.keys.include? :pacient_id
      Nahravka.create(params.permit(:pacient_id, :filename, :f0rise))
    else
      pacient = Pacient.where(params.permit(:meno, :priezvisko, :vek, :pohlavie)).first_or_create
      pacient.nahravky.create(params.permit(:filename, :f0rise))
    end
    render json: {status: 'OK'}
  end

  def show
    nahravka = Nahravka.find(params[:id])
    render json: nahravka
  end
end