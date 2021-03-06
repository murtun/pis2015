class PeopleController < ApplicationController

  skip_before_action :admin?, only:[:show, :index, :me, :show_pending_timeline,
                                    :show_not_pending_timeline,:add_skill,:add_skill_form,:remove_skill,
                                    :remove_skill_form, :show_timeline_cat_fil, :edit, :update]
  #skip_before_action :admin?, only:[:assign_project]
  before_action :get_person, only:[:show, :edit, :update, :show_pending_timeline, :show_not_pending_timeline, :switch_admin]

  DEFAULT_IMAGE_ID = "lfblntfejcpmmkh0wfny.jpg"

  @@tl_page_size = 10 #tamaño de pagina de timeline

  def get_person
    identifier = params[:id]
    @person = Person.find_by(id: params[:id] || params[:person_id])
    unless @person
      # El identificador lo comparo en minuscula con la base de datos
      identifier = identifier.downcase
      # En el caso que sea un nombre, se sustituyen las _ por espacios
      @person = Person.where("lower(name)= :name", name:"#{identifier.gsub(/_/, "\s")}").first
      unless @person
        @person = Person.where("lower(email) LIKE :prefix", prefix:"#{identifier}@%").first
      end
    end
  end

  def index

    @people = Person.all.order('LOWER(name)')
    #@people = Person.paginate(:page => params[:page], :per_page => 10).order('LOWER(name)')

    respond_to do |f|

      f.html {
        if !current_user_admin?
          me
        end
      }

      f.json { render json: name_and_path(Person.all)}
    end

  end

  def me
    p = current_person
    redirect_to action: 'show', id: p.id
  end

  def show
    if @person
      #nombre
      @name = @person.name
      @identifier = @person.id
      user = Person.find(current_user.person_id)
      #ASSIGN PEOPLE
      if current_user_admin?
        @people= Person.all.where('id NOT in (?)', @identifier)
      else
        @people= user.mentees.where('mentee_id NOT in (?) ', @identifier)
        unless user.id==@identifier
          @people<<user
        end
      end
      #CATEGORIES PEOPLE
      @cats = Category.all.order('LOWER(name)').collect {|t| [t.name, t.id, 'isfeedback' => t.is_feedback]}

      @authors = Person.all.where('id NOT in (?)', @identifier).collect {|t| [t.name, t.id]}
      @tags = Tag.where(validity: true).order('LOWER(name)')

      #rol tecnico
      @trole = ''
      @trole = @person.tech_role.name if @person.tech_role

      #habilidades
      @skills = @person.skills.order('LOWER(name)')

      #proyectos
      #@proysin = @person.projects.where('Projects.end_date IS NULL OR Projects.end_date >= CURRENT_DATE')
      #@proysend = @person.projects.where("Projects.end_date < CURRENT_DATE").length

      @proysin = @person.projects.where('projects.status <> ?', Project.statuses[:finished]).order('LOWER(name)')
      @proysend = @person.projects.where('projects.status = ?', Project.statuses[:finished]).length

      @image_id = @person.image_id

      #tiempo en moove-it
      @start_date = @person.start_date
      #Eventos (Hitos)
      @events = @person.milestones.where("milestones.due_date >= CURRENT_DATE AND milestones.status = 0 AND milestones.category_id = 1").order(due_date: :desc, created_at: :desc)

      #Hitos pendientes
      @overcomes = @person.milestones.where("milestones.due_date < CURRENT_DATE AND milestones.status = 0").order(due_date: :desc, created_at: :desc)

      #Mentores
      @mentorships = @person.mentors.order('LOWER(name)')
      @yet_pending = Milestone.pending.where('id NOT in (?)', @person.milestones.pluck(:id))

      #
      @temps = Template.all.order(title: :desc)
      @collections = Collection.all.order(title: :desc)
      show_pending_timeline

    else
      redirect_to root_path
    end
  end

  def show_not_pending_timeline
    apply_filter_not_pending
    @filtered_not_pending_count = @milestones.size
    @filtered_pending_count = @person.milestones.size - @filtered_not_pending_count

    @milestones = @milestones.limit(@@tl_page_size)
    @filter = :not_pending

    @hay_mas = (@filtered_not_pending_count > @@tl_page_size)
    @page = '2'
    respond_to do |f|
      f.js {render 'people/show_timeline'}
      f.html {}
    end
  end

  def show_pending_timeline
    apply_filter_pending
    @filtered_pending_count = @milestones.size
    @milestones = @milestones.limit(@@tl_page_size)

    @filtered_not_pending_count = @person.milestones.size - @filtered_pending_count

    @filter = :pending
    @hay_mas = (@filtered_pending_count > @@tl_page_size)
    @page = '2'
    respond_to do |f|
      f.js {render 'people/show_timeline'}
      f.html {}
    end
  end

  def apply_filter_pending
    @milestones = @person.milestones.where('milestones.status = 0').order(highlighted: :desc, due_date: :asc, updated_at: :desc)
  end

  def apply_filter_not_pending
    @milestones = @person.milestones.where('milestones.status <> 0').order(updated_at: :desc,completed_date: :desc)
  end

  def show_timeline_cat_fil
    @person = Person.find_by(id: params[:person_id])

    if params[:filter] == 'not_pending'
      apply_filter_not_pending
    else
      apply_filter_pending
    end
    @milestones =@milestones.where("milestones.category_id = #{params[:category_id]}") if (params[:category_id].present? && params[:category_id]!='-1')
    @category_id = params[:category_id]

    @filtered_count = @milestones.size
    if params[:page].present?
      page = params[:page].to_i
    else
      page = 1
    end

    offset = @@tl_page_size*(page - 1)
    @milestones = @milestones.limit(@@tl_page_size).offset(offset)


    @filter = params[:filter]
    @hay_mas = @filtered_count > (page * @@tl_page_size)
    @page = page + 1


    respond_to do |f|
      if params[:paging].present?
        f.js {render 'people/show_inner_timeline'}
      else
        f.js {render 'people/show_timeline'}
      end
      f.html {}
    end
  end

  def new
    @person = Person.new
    @roles=TechRole.where(validity: true).order('LOWER(name)')
    @skills= Skill.where(validity: true).order('LOWER(name)')
  end

  def create
    @person = Person.new(person_params.except(:image_id))
    if person_params[:image_id].present?
      preloaded = Cloudinary::PreloadedFile.new(person_params[:image_id])
      raise "Invalid upload signature" if !preloaded.valid?
      @person.image_id = preloaded.identifier
    end

    @person.skill_ids=params[:skills]
    if @person.valid?
      @person.save
      flash.notice = "'#{person_params[:name]}' " + t('messages.create.success')
      redirect_to '/people'
    else
      flash.alert = "'#{person_params[:name]}' " + t('messages.create.error')
      @roles=TechRole.where(validity: true).order('LOWER(name)')
      render :action =>'new'
    end
  end

  def assign_milestone
    milestone=Milestone.find(params[:milestone_id])
    person=Person.find(params[:person_id])
    person.milestones<<milestone
    redirect_to person
  end

  # def assign_project
  #  pj_id= params[:project_id]
  #  id= params[:person_id]
  #  project= Project.find(pj_id)
  #  person= Person.find(id)
  #  if not project.people.exists?(id)
  #    project.people<< person
  #    project.save
  #  end
  #  redirect_to person
  #end

  def edit
    unless can_view_person? @person.id
      flash.alert= t('not_authorized')
      redirect_to people_path
    end
    @skills=Skill.where(validity: true).order('LOWER(name)')
    @roles=TechRole.where(validity: true).order('LOWER(name)')
  end

  def update

    old_person = Person.find(@person.id)
    old_role = old_person.tech_role

    @person.tech_role_id=params[:tech_role_id]
    if @person.update_attributes(person_params.except(:image_id))
      @person.skill_ids=params[:skills]
      if person_params[:image_id].present?
        preloaded = Cloudinary::PreloadedFile.new(person_params[:image_id])
        raise "Invalid upload signature" if !preloaded.valid?
        @person.image_id = preloaded.identifier
        @person.save
      end

      if old_role != @person.tech_role
        ev = ChangeRoleEvent.new(new_role: @person.tech_role, old_role: old_role,
                                 author: current_person, person: @person)
        ev.fire
      end

      redirect_to @person
    else
      redirect_to edit_person_path
    end
  end

  def add_mentor
    if (params[:mentor_id] != params[:mentee_id])
      @mentor=Person.find(params[:mentor_id])
      @mentee=Person.find(params[:mentee_id])
      begin
        @mentor.mentees_assignations.create! start_date: params[:start_date], mentee: @mentee
        redirect_to @mentee
      rescue ActiveRecord::RecordNotUnique
        redirect_to @mentee # el mentor ya fue asignado por otro usuario. El resultado es el mismo. Ignoro el error.
      rescue Exception
        render :status => 500, :file => "public/500"
      end

    else
      render :status => 422, :file => "public/422"
    end
  end

  def add_mentor_form
    @mentee=Person.find(params[:mentee_id])
    @posible_mentors=Person.all.where("id NOT IN (SELECT mentor_id FROM mentorships WHERE mentee_id=?) AND id<>?",params[:mentee_id], params[:mentee_id]).order('LOWER(name)')
    render :file => "app/views/people/add_mentor_form"
  end


  def switch_admin
    @person.admin = !@person.admin
    @person.save!
    redirect_to :back
  end


  def remove_mentor_form
    @mentee=Person.find(params[:mentee_id])
    @mentors = @mentee.mentors
  end

  def remove_mentor
    if (params[:mentor_id] != params[:mentee_id])
      @mentor=Person.find(params[:mentor_id])
      @mentee=Person.find(params[:mentee_id])

      #Eliminar mentor
      ma = Mentorship.find_by(mentor_id: params[:mentor_id], mentee_id: params[:mentee_id])
      if ma
        ma.destroy!
      end
      redirect_to @mentee

    else
      render :status => 422, :file => "public/422"
    end
  end

  def add_skill_form
    @person=Person.find(params[:person_id])
    @posible_skills=Skill.all.where("id NOT IN (SELECT skill_id FROM person_skills WHERE person_id=?)",params[:person_id]).where('validity': true).order('LOWER(name)')
    render :file => "app/views/people/add_skill_form"
  end

  def remove_skill_form
    @person=Person.find(params[:person_id])
    @skills = @person.skills
  end

  def add_skill

    person=Person.find(params[:person_id])
      skill = Skill.find(params[:skill_id])
      if person && skill
        person.skills<<(skill)

        #generar hito
        milestone = Milestone.new
        milestone.author = current_person
        milestone.completed_date = Time.now
        milestone.status = :done
        milestone.people << person
        milestone.category = Category.get_or_create_history_category
        milestone.icon = milestone.category.icon
        milestone.title = "#{person.name} #{I18n.translate('skills.addrm.new.title')}"
        milestone.description = "#{person.name} #{I18n.translate('skills.addrm.new.desc1')} '#{skill.name}'"
        milestone.save!
      end

    redirect_to person
  end

  def remove_skill
    person=Person.find(params[:person_id])
      skill = Skill.find(params[:skill_id])

      #Eliminar mentor
      ps = PersonSkill.find_by(person_id: params[:person_id], skill_id: params[:skill_id])
      if ps
        ps.destroy!

        #generar hito
        milestone = Milestone.new
        milestone.author = current_person
        milestone.completed_date = Time.now
        milestone.status = :done
        milestone.people << person
        milestone.category = Category.get_or_create_history_category
        milestone.icon = milestone.category.icon
        milestone.title = "#{I18n.translate('skills.addrm.rm.title')} #{person.name}"
        milestone.description = "#{person.name} #{I18n.translate('skills.addrm.rm.desc1')} '#{skill.name}'"
        milestone.save!
      end

    redirect_to person
  end

  private
  def person_params
    params.require(:person).permit(:name, :email, :cellphone, :phone, :birth_date, :start_date, :image_id, :tech_role_id)
  end


  def name_and_path (people)

    people.map do |p|
      {"photo" => (p.image_id || "lfblntfejcpmmkh0wfny.jpg"),"name" => p.name, "url" => person_path(p)}
    end

  end


end
