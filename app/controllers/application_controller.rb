class ApplicationController < ActionController::Base
  before_action :load_members
  before_action :loged?
  before_action :admin?

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  #Si el usar no esta logueado redirecciona a login
  def loged?
    @user = current_user
    if not @user
        redirect_to welcome_index_path
    end
  end

  #Si el user no es admin, redirecciona a root path
  def admin?
    @user = current_user
    if @user
      @person = Person.find(@user.person_id)
      if !(@person.admin)
        redirect_to root_path
      end
    end
  end

  #Devuelve el usuario logueado o nil si no lo hay
  helper_method :current_user
  def current_user
    @current_user ||= User.find_by(id: session[:user_id]) if (session[:user_id]) && (User.find_by(id: session[:user_id])) && (!(User.find_by(id: session[:user_id]).oauth_expired?))
  end

  helper_method :navigation_bar_visible

  attr_accessor :navigation_bar_visible
  private

  def load_members
    @navigation_bar_visible = true
  end

  #Devuelve el dia de la semana de un date
  helper_method :dayname
  def dayname(date)
    days = ['Dom', 'Lun', 'Mar', 'Mier', 'Jue', 'Vie', 'Sab']
    @dayname ||= days[date.wday]
  end

  #Devuelve el mes de un date
  helper_method :monthname
  def monthname(date)
    monthes = ['', 'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio', 'Julio', 'Agosto', 'Setiembre', 'Octubre', 'Noviembre', 'Diciembre']
    @monthname ||= monthes[date.month]
  end

end
