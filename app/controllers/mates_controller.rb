class MatesController < ApplicationController
  before_action :load_mate, only: [:show, :edit, :update, :destroy]

  def index
    @mates = Mate.all
  end

  def show
  end

  def new
    @mate = Mate.new
  end

  def create
    @mate = Mate.new(mate_params)

    if @mate.save
      redirect_to mate_path(@mate), notice: 'account created'
    end
  end

  def edit
  end

  def update
    if @mate.update_attributes(mate_params)
      redirect_to mate_path(@mate), notice: 'account updated'
    else
      render :edit
    end
  end

  def destroy
    @mate.destroy
    redirect_to root_path, notice: 'account deleted'
  end

  private
  def mate_params
    params.require(:mate).permit(:first_name, :last_name, :username, :email, :password, :password_confirmation)
  end

  def load_mate
    @mate = Mate.find(params[:id])
  end

end