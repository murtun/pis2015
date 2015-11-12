class TechnologiesController < ApplicationController

  skip_before_action :admin?, only:[:show, :index]
  before_action :get_technology, only:[:edit, :update, :destroy]

  DEFAULT_ICON = "lfblntfejcpmmkh0wfny.jpg"

  def get_technology
    @technology = Technology.find_by(id: params[:id])
  end

  def index
    @technologies = Technology.where(validity: 'true').paginate(:page => params[:page], :per_page => 10).order('LOWER(name)')
  end

  def edit

  end

  def new

  end

  def show
    redirect_to technologies_path
  end

  def create
    @technology=Technology.new(technology_params.except(:icon))
    if technology_params[:icon].present?
      preloaded = Cloudinary::PreloadedFile.new(technology_params[:icon])
      raise "Invalid upload signature" if !preloaded.valid?
      @technology.icon = preloaded.identifier
    end
    @technology.save
    if @technology.valid?
      flash.notice = "#{technology_params[:name]} " + t('messages.create.success')
    else
      flash.alert = "#{technology_params[:name]} " + t('messages.create.error')
    end
    redirect_to technologies_path
  end


  def update
    if @technology.update(technology_params.except(:icon))
      if technology_params[:icon].present?
        preloaded = Cloudinary::PreloadedFile.new(technology_params[:icon])
        raise "Invalid upload signature" if !preloaded.valid?
        @technology.icon = preloaded.identifier
        @technology.save
      end
      flash.notice = "#{technology_params[:name]} " + t('messages.save.success')
      redirect_to technologies_path
    else
      flash.alert = "#{technologies_path[:name]} " + t('messages.save.error')
      render :edit
    end
  end

  def destroy
    if @technology
      name = @technology.name
      @technology.validity = false
      @technology.save
      flash.notice = "#{name} " + t('messages.delete.success')
    end
    redirect_to technologies_path
  end

  private
  def technology_params
    params.require(:technology).permit(:name, :icon)
  end


end