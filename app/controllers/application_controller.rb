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
      # @person = Person.find(@user.person_id)
      if !(@user.person.admin)
        redirect_to root_path
      end
    end
  end

  #Devuelve el usuario logueado o nil si no lo hay
  helper_method :current_user
  def current_user
    @current_user ||= User.find_by(id: session[:user_id]) if (session[:user_id]) && (User.find_by(id: session[:user_id])) && (!(User.find_by(id: session[:user_id]).oauth_expired?))
  end

  helper_method :current_person
  def current_person
    if current_user
      current_user.person
    else
      nil
    end
  end


  #devuelve true si hay usr logueado y es admin, false en otro caso.
  helper_method :current_user_admin?
  def current_user_admin?
    user = current_user
    if user
      user.person.admin
    else
      false
    end

  end

=begin
  # No esta más en peopleController, hay que ver si se usa
  #devuelve true si puedo ver el perfil de la persona person_id, false de lo contrario.
  helper_method :can_view_person?
  def can_view_person? (person_id)
    user = current_user
    current_person = Person.find_by(id: user.person_id)
    view_person = Person.find_by(id: person_id)
    if user and (user.person.admin or (user.person_id == person_id) or (current_person.mentees.include? view_person))
      true
    elsif not user
      redirect_to root_path
    else
      false
    end
  end
=end

  #devuelve true si puedo ver el hito milestone_id, false de lo contrario.
  #se usa? en view no, y para checkear en milestone ya hay otra funcion
  helper_method :can_modify_milestone?
  def can_modify_milestone? (milestone_id)
    user = current_user
    current_person = Person.find_by(id: user.person_id)
    edit_milestone = Milestone.find_by(id: milestone_id)
    mentee_mil=false
    current_person.mentees.all.each do |m|
      if m.milestones.exists? edit_milestone.id
        mentee_mil=true
      end
    end
    user && (user.person.admin ||
        (current_person.milestones.include? edit_milestone) ||
        mentee_mil )
    #   true
    # elsif not user
    #   redirect_to root_path
    # else
    #   menteesmilestone = false
    #   current_person.mentees.each do |mentee|
    #     menteesmilestone = menteesmilestone || (mentee.milestones.include? view_milestone)
    #   end
    #   menteesmilestone
  end



  helper_method :navigation_bar_visible

  attr_accessor :navigation_bar_visible
  private

  def load_members
    @navigation_bar_visible = true
  end

  # Gurdar url anterior
  helper_method :store_return_to
  def store_return_to
    session[:return_to] = request.url
  end
end
