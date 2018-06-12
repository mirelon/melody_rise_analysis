class PacientController < ApiController
  def create
    Pacient.create(params.permit(:meno, :priezvisko, :vek, :pohlavie))
    render json: {status: 'OK'}
  end

  def show
    render json: Pacient.find(params[:id])
  end
end
