class MilestonesController < ApplicationController

  skip_before_action :admin?

  def index
    @milestone= Milestone.all
  end

  def new
    @milestone=Milestone.new
  end

  def create
    @milestone=Milestone.new(milestone_params)
    @milestone.save
    redirect_to @milestone
  end

  def create_from_person
    @person=Person.find(params[:person_id])
    @milestone= @person.milestones.create(milestone_params)
    redirect_to @milestone
  end

  def show
    @milestone=Milestone.find(params[:id])
  end

  def destroy
    @milestone= Milestone.find(params[:id])
    @milestone.destroy
    redirect_to milestones_path
  end
	
  def edit
    @milestone = Milestone.find(params[:id])
  end
	
  def update
    @milestone = Milestone.find(params[:id])
    if @milestone.update_attributes(milestone_params)
      redirect_to @milestone
    end
  end

  def markasdone
    milestone = Milestone.find_by(id: params[:m_id])
    milestone.status= :done
    milestone.save!
    redirect_to session.delete(:return_to)
  end

  private
  def milestone_params
    params.require(:milestone).permit(:title,:due_date,:description,:status, :icon, :created_at, :updated_at)
  end
end
