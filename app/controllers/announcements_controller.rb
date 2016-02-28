class AnnouncementsController < ApplicationController
  before_action :load_house, only: [:new, :create, :edit, :update]

  def index
    @announcements = Announcement.where(house_id: params[:house_id])
  end

  def show
    @announcement = Announcement.find(params[:id])
  end

  def new
    @announcement = Announcement.new
  end

  def create
    @announcement = @house.announcements.build(announcement_params)
    @announcement.mate = current_user

    if @announcement.save
      redirect_to house_path(@house), notice: "Announcement added to house"
    else
      render :new
    end

  end

  def edit
    @announcement = Announcement.find(params[:id])
  end

  def update
    @announcement = Announcement.find(params[:id])

    if @announcement.update_attributes(announcement_params)
      redirect_to house_path(@announcement.house_id), notice: "Announcement updated"
    else
      render :edit
    end

  end

  def destroy
  end

  private
  def announcement_params
    params.require(:announcement).permit(:title, :body)
  end

  def load_house
    @house = House.find(params[:house_id])
  end

end
