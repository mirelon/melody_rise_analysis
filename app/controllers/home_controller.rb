class HomeController < ApplicationController
  skip_before_action :verify_authenticity_token, :only => [:upload]

  def index
    @pacienti = Pacient.all
    @nahravky = Nahravka.all
  end

  def upload
    pacient = Pacient.where(params.permit(:meno, :priezvisko, :vek, :pohlavie)).first_or_create
    nahravka = pacient.nahravky.create(data_uri: params[:data])
    render json: nahravka
  end
end
