class MilestonesController < ApplicationController


  before_action :get_milestone, only: [:add_category, :next_status]
  before_action :get_milestone_by_id, only: [:feedback?, :update, :edit, :show, :destroy]
  before_action :get_category, only: [:add_category]
  before_action :is_authorized?, only: [:edit,:update,:destroy, :add_category]
  skip_before_action :admin?

  def is_authorized?
    unless can_modify_milestone? @milestone.id
      flash.alert = t('not_authorized')
      redirect_to '/people'
    end
  end

  def get_milestone
    @milestone=Milestone.find(params[:milestone_id])
  end

  def get_milestone_by_id
    @milestone=Milestone.find_by(id: params[:id])
    if @milestone.nil?
      redirect_to '/milestones'
    end
  end

  def get_category
    @category=Category.find(params[:category_id])
  end

  def index
    @milestone= Milestone.all
    respond_to do |f|
      f.json { render json: name_and_path(@milestone)}
      f.html { render }
    end

  end

  def new
    redirect_to '/people'
  end


  def create
    @person=Person.find(params[:person_id])
    @milestone= @person.milestones.create(milestone_params)
    @milestone.tag_ids = params[:tags]
    #CATEGORIES
    category=Category.find(params[:milestone][:category_id])
    @milestone.category=category
    if category.name=='Feedback'
      @milestone.feedback_author_id=params[:milestone][:feedback_author_id]
    end
    #ASSIGNED
    if params[:people]!=nil
      params[:people].each do |p|
      @person2=Person.find(p)
      @milestone.people<<@person2
      end
    end
    @milestone.save
    if @milestone.valid?
      flash.notice = "'#{milestone_params[:title]}' " + t('messages.create.success')
      redirect_to @person
    else
      flash.alert = "'#{milestone_params[:title]}' " + t('messages.create.error')
      redirect_to @person
    end

  end


  def add_category
    @category.milestones<<@milestone
    redirect_to @milestone
  end
  # Por ahora queda asi, deberia ser @milestone.category= @category

  def show
    @notes = @milestone.notes.includes(:author).order(created_at: :desc).select {|n| filter_note_by_visibility(n)}
  end

  def destroy
    @milestone.notes.each do |n|
      n.destroy
    end
    @milestone.destroy
    redirect_to milestones_path
  end

  def edit
    @cats=Category.all.collect {|t| [t.name, t.id]}
    @authors=Person.all.collect {|t| [t.name, t.id]}
    @tags = Tag.all
    user= Person.find(current_user.person_id)
    if current_user_admin?
      @people= Person.all.where('id NOT in (?)', @milestone.people.map{|p| p.id})
    else
      @people= user.mentees.where('mentee_id NOT in (?)', @milestone.people.map{|p| p.id})
      unless @milestone.people.exists?(user.id)
        @people<<user
      end
    end
    @category_name = @milestone.category.name
  end

  def update
    category=Category.find(params[:milestone][:category_id])
      if category.name == 'Feedback'
        @milestone.feedback_author_id=params[:milestone][:feedback_author_id]
      else
        @milestone.feedback_author_id=nil
      end
      @milestone.category = category
      if params[:people]!=nil
        params[:people].each do |p|
          @person2=Person.find(p)
          @milestone.people<<@person2
          @milestone.save
        end
      end
      @milestone.category = category
      if @milestone.update_attributes(milestone_params)
        @milestone.tag_ids = params[:tags]
        redirect_to @milestone
      else
        render :edit
      end
  end

  helper_method :feedback?
  def feedback?
    return @milestone.category.name == 'Feedback'
  end

  def next_status
    if @milestone.status == 'pending'
      @milestone.status= 'done'
    else
      @milestone.status= 'pending'
    end

    @milestone.save!
    redirect_to :back
  end

  def next_status_rej
    @milestone = Milestone.find_by(id: params[:milestone_id])
    if @milestone.status == 'rejected'
      @milestone.status= 'pending'
    else
      @milestone.status= 'rejected'
    end
    @milestone.save!
    redirect_to :back
  end

  def filter_note_by_visibility(note)
      (note.visibility=='every_body') ||
      (note.author_id==current_person.id) || #la hice yo?
      (note.visibility=='mentors' && Person.find(note.author_id).mentors.exists?(current_person.id)) || #si es para mentores, soy su mentor
      (current_person.admin?)
  end

  private

  def milestone_params
    params.require(:milestone).permit(:title, :start_date, :due_date,:description,:status, :icon, :created_at, :updated_at)
  end


  def name_and_path (milestone)
    milestone.map do |p|
      {"name" => p.title, "url" => milestone_path(p)}
    end
  end


end
